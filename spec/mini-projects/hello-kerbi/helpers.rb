module HelloKerbi
  module Helpers
    def img2alpine(img_name)
      return img_name if img_name.include?(":")
      "#{img_name}:alpine"
    end
  end
end