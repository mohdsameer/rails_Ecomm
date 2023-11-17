module ApplicationHelper
	def display_image(image, default_image)
    if image.attached?
      image_tag image, alt: "image", class: "section_img"
    elsif default_image.present?
      image_tag default_image, alt: "image", class: "section_img"
    end
  end
end
