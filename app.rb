require "roda"

require "./config/sequel"
require "./config/shrine"

require "./uploaders/image_uploader"
require "./models/photo"

class App < Roda
  plugin :public

  plugin :render
  plugin :partials
  plugin :forme

  plugin :all_verbs
  use Rack::MethodOverride

  route do |r|
    r.public

    r.root do
      r.redirect "/photos"
    end

    r.on "photos" do
      # GET /photos
      r.get true do
        photos = Photo.all

        view "photos/index", locals: { photos: photos }
      end

      # GET /photos/new
      r.get "new" do
        photo = Photo.new

        view "photos/new", locals: { photo: photo }
      end

      # POST /photos
      r.post true do
        photo = Photo.new(r.params["photo"])

        if photo.valid?
          photo.save
          r.redirect "/photos/#{photo.id}"
        else
          view "photos/new", locals: { photo: photo }
        end
      end

      r.on Integer do |photo_id|
        photo = Photo.with_pk!(photo_id)

        # GET /photos/:id
        r.get true do
          view "photos/show", locals: { photo: photo }
        end

        # PUT /photos/:id
        r.put true do
          photo.set(r.params["photo"])

          if photo.valid?
            photo.save
            r.redirect "/photos/#{photo.id}"
          else
            view "photos/show", locals: { photo: photo }
          end
        end
      end
    end

    r.on "upload" do
      r.run Shrine.upload_endpoint(:cache)
    end

    r.on "derivations/image" do
      r.run ImageUploader.derivation_endpoint
    end
  end
end
