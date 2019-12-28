function fileUpload(fileInput) {
  var formGroup = fileInput.parentNode
  var hiddenInput = document.querySelector('.upload-data')
  var imagePreview = document.querySelector('.image-preview img')

  formGroup.removeChild(fileInput)

  var uppy = Uppy.Core({
      autoProceed: true,
      restrictions: {
        allowedFileTypes: fileInput.accept.split(','),
      }
    })
    .use(Uppy.FileInput, {
      target: formGroup,
      locale: { strings: { chooseFiles: 'Choose file' } },
    })
    .use(Uppy.Informer, {
      target: formGroup,
    })
    .use(Uppy.ProgressBar, {
      target: imagePreview.parentNode,
    })
    .use(Uppy.ThumbnailGenerator, {
      thumbnailWidth: 600,
    })
    .use(Uppy.XHRUpload, {
      endpoint: '/upload',
    })

  uppy.on('upload-success', function (file, response) {
    imagePreview.src = response.uploadURL

    var uploadedFileData = JSON.stringify(response.body['data'])

    hiddenInput.value = uploadedFileData

    var copper = new Cropper(imagePreview, {
      aspectRatio: 1,
      viewMode: 1,
      guides: false,
      autoCropArea: 1.0,
      background: false,
      crop: function (event) {
        data = JSON.parse(hiddenInput.value)
        data['metadata']['crop'] = event.detail
        hiddenInput.value = JSON.stringify(data)
      }
    })
  })
}

document.querySelectorAll('input[type="file"]').forEach(function (fileInput) {
  fileUpload(fileInput)
})
