class ShippoService
  attr_reader :order, :sender, :shipment_errors, :parcel, :address_from, :address_to, :shipment, :rates

  def initialize(order:)
    Shippo::API.token = ENV['SHIPPO_API_KEY']

    @order  = order
    @sender = order.sender

    @shipment_errors = []

    @parcel       = nil
    @address_from = nil
    @address_to   = nil
    @shipment     = nil
    @rates        = []
  end

  def ensure_sender
    @sender = order.create_sender unless sender.present?
  end

  def ensure_sender_address
    unless sender.address.present?
      producer = order.producers.last

      sender.create_address(
        producer.address.attributes.except(
          'id', 'addressable_id', 'addressable_type','shippo_address_id', 'created_at', 'updated_at'
        )
      )
    end
  end

  def sender_address
    @sender_address ||= order.sender.address
  end

  def recipient_address
    @recipient_address ||= order.address
  end

  def dimensions
    @dimensions ||= order.package_dimensions
  end

  def dimensions_hash
    dimensions_hash = {
      length:        dimensions[:length],
      width:         dimensions[:width],
      height:        dimensions[:height],
      distance_unit: :in,
    }

    if dimensions[:weight_lb].present? && dimensions[:weight_lb] > 0
      dimensions_hash[:mass_unit] = :lb
      dimensions_hash[:weight]    = dimensions[:weight_lb]
    elsif dimensions[:weight_oz].present? && dimensions[:weight_oz] > 0
      dimensions_hash[:mass_unit] = :oz
      dimensions_hash[:weight]    = dimensions[:weight_oz]
    else
      dimensions_hash[:mass_unit] = :lb
      dimensions_hash[:weight]    = 1.0
    end

    dimensions_hash
  end

  def create_parcel
    begin
      @parcel = Shippo::Parcel.create(dimensions_hash)
      order.update(shippo_parcel_id: @parcel['object_id'])
      order.reload
    rescue => e
      @shipment_errors << 'Problem in package dimensions'
    end
  end

  def retrieve_parcel
    begin
      @parcel = Shippo::Parcel.get(order.shippo_parcel_id)
    rescue => e
      @shipment_errors << 'Unable to fetch shipping parcel'
    end
  end

  def find_or_create_parcel
    if order.shippo_parcel_id.present?
      retrieve_parcel
    else
      create_parcel
    end
  end

  def create_address_from
    begin
      @address_from = Shippo::Address.create(
        name:    sender_address.fullname,
        street1: sender_address.address1,
        street2: sender_address.address2,
        city:    sender_address.city,
        state:   sender_address.state,
        zip:     sender_address.zipcode,
        country: sender_address.country,
        phone:   sender_address.num,
        email:   sender_address.email
      )

      sender_address.update(shippo_address_id: @address_from["object_id"])
      sender_address.reload
    rescue => e
      @shipment_errors << 'Problem in sender address'
    end
  end

  def retrieve_address_from
    begin
      @address_from = Shippo::Address.get(sender_address.shippo_address_id)
    rescue => e
      @shipment_errors << "Unable to get sender address"
    end
  end

  def find_or_create_address_from
    if sender_address.present?
      sender_address.shippo_address_id.present? ? retrieve_address_from : create_address_from
    else
      @shipment_errors << "Sender address not present"
    end
  end

  def create_address_to
    begin
      @address_to = Shippo::Address.create(
        name:    order.address.fullname,
        street1: order.address.address1,
        street2: order.address.address2,
        city:    order.address.city,
        state:   order.address.state,
        zip:     order.address.zipcode,
        country: order.address.country,
        phone:   order.address.num,
        email:   order.address.email
      )

      order.address.update(shippo_address_id: @address_to["object_id"])
      order.reload
    rescue => e
      @shipment_errors << "Problem in recipient address"
    end
  end

  def retrieve_address_to
    begin
      @address_to = Shippo::Address.get(order.address.shippo_address_id)
    rescue => e
      @shipment_errors << "Unable to fetch recipient address"
    end
  end

  def find_or_create_address_to
    if order.address.present?
      order.address.shippo_address_id.present? ? retrieve_address_to : create_address_to
    else
      @shipment_errors << "Recipient address not present"
    end
  end

  def create_shippo_shipment
    begin
      @shipment = Shippo::Shipment.create(
        address_from: address_from,
        address_to:   address_to,
        parcels:      parcel,
        async:        false
      )

      order.update(shippo_shipment_id: @shipment["object_id"])
      order.reload
    rescue => e
      @shipment_errors << 'Unable to create shipment'
    end
  end

  def create_shipment
    ensure_sender
    ensure_sender_address
    find_or_create_parcel
    find_or_create_address_from
    find_or_create_address_to

    create_shippo_shipment if address_from.present? && address_to.present? && parcel.present?

    @order  = order.reload
    @sender = sender.reload
  end

  def rates
    @rates = shipment.present? ? shipment["rates"] : []
  end

  def error_message
    @shipment_errors.join(', ')
  end

  def shipment_has_error
    @shipment_errors.size > 0
  end
end
