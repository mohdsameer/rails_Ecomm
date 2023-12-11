module ApplicationHelper
	def display_image(image, default_image)
    if image.attached?
      image_tag image, alt: "image", class: "section_img"
    elsif default_image.present?
      image_tag default_image, alt: "image", class: "section_img"
    end
  end

  def pagination_information(records)
    per_page      = records.per_page
    total_entries = records.total_entries
    current_page  = records.current_page.to_i

    first_count = ((current_page - 1) * per_page) + 1
    last_count  = first_count + (records.entries.count - 1)

    "#{first_count}-#{last_count} of #{total_entries}"
  end
end
