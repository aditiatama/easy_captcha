module EasyCaptcha
  module Generator

    # default generator
    class Default < Base

      # set default values
      def defaults
        @font_size              = 24
        @font_fill_color        = '#333333'
        @font_family            = File.expand_path('../../../../resources/captcha.ttf', __FILE__)
        @font_stroke            = '#000000'
        @font_stroke_color      = 0
        @image_background_color = '#FFFFFF'
        @sketch                 = true
        @sketch_radius          = 3
        @sketch_sigma           = 1
        @wave                   = true
        @wave_length            = (60..100)
        @wave_amplitude         = (3..5)
        @implode                = 0.05
        @blur                   = true
        @blur_radius            = 1
        @blur_sigma             = 2
      end

      # Font
      attr_accessor :font_size, :font_fill_color, :font_family, :font_stroke, :font_stroke_color

      # Background
      attr_accessor :image_background_color

      # Sketch
      attr_accessor :sketch, :sketch_radius, :sketch_sigma

      # Wave
      attr_accessor :wave, :wave_length, :wave_amplitude

      # Implode
      attr_accessor :implode

      # Gaussian Blur
      attr_accessor :blur, :blur_radius, :blur_sigma

      def sketch? #:nodoc:
        @sketch
      end

      def wave? #:nodoc:
        @wave
      end

      def blur? #:nodoc:
        @blur
      end

      # generate image
      def generate(code, file = nil)
        config = self
        canvas = Magick::Image.new(EasyCaptcha.image_width, EasyCaptcha.image_height) do |variable|
          self.background_color = config.image_background_color unless config.image_background_color.nil?
        end

        # Render the text in the image
        canvas.annotate(Magick::Draw.new, 0, 0, 0, 0, code) {
          self.gravity     = Magick::CenterGravity
          self.font_family = config.font_family
          self.font_weight = Magick::LighterWeight
          self.fill        = config.font_fill_color
          if config.font_stroke.to_i > 0
            self.stroke       = config.font_stroke_color
            self.stroke_width = config.font_stroke
          end
          self.pointsize = config.font_size
        }

        # Blur
        canvas = canvas.blur_image(config.blur_radius, config.blur_sigma) if config.blur?

        # Wave
        w = config.wave_length
        a = config.wave_amplitude
        canvas = canvas.wave(rand(a.last - a.first) + a.first, rand(w.last - w.first) + w.first) if config.wave?

        # Sketch
        canvas = canvas.sketch(config.sketch_radius, config.sketch_sigma, rand(180)) if config.sketch?

        # Implode
        canvas = canvas.implode(config.implode.to_f) if config.implode.is_a? Float

        # Crop image because to big after waveing
        canvas = canvas.crop(Magick::CenterGravity, EasyCaptcha.image_width, EasyCaptcha.image_height)

        unless file.nil?
          canvas.write(file) { self.format = 'PNG' }
        end
        image = canvas.to_blob { self.format = 'PNG' }
        canvas.destroy!
        image
      end

    end
  end
end