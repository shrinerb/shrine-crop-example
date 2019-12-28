# Shrine Crop Example

[Roda] & [Sequel] app showing image cropping with [Shrine] and [Cropper.js].

## Setup

You'll need to have [libvips] installed:

```sh
$ brew install vips
```

You'll also need to create the Postgres database:

```sh
$ createdb shrine-crop-example
```

Now you can run the following to get the app up and running:

```sh
$ bundle install
$ bundle exec rake db:migrate
$ bundle exec rackup
```

## How it works

When the user selects an image, it gets uploaded asynchronously to temporary
storage via Shrine's [upload endpoint].

Then the user is presented with a cropping UI powered by Cropper.js. Whenever
the cropping points are moved, the cached file metadata in the hidden attachment
field is updated with the current cropping data.

When the form gets submitted, the cached file is persisted along with the
cropping metadata. Then a [background job] is automatically kicked off to crop
the image and generate thumbnails from the result.

While the background job is processing, the cropped thumbnail link uses the
[on-the-fly processing endpoint][derivation endpoint]. Once the background job
is finished, cropped thumbnails are served directly from the storage.

[Roda]: https://roda.jeremyevans.net/
[Sequel]: https://sequel.jeremyevans.net/
[Shrine]: https://shrinerb.com
[Cropper.js]: https://fengyuanchen.github.io/cropperjs/
[libvips]: http://libvips.github.io/libvips/
[upload endpoint]: https://shrinerb.com/docs/plugins/upload_endpoint
[background job]: https://shrinerb.com/docs/plugins/backgrounding
[derivation endpoint]: https://shrinerb.com/docs/plugins/derivation_endpoint
