$(document).on('turbolinks:load', function() {
  $('.select2').select2({
    tags: true,
    placeholder: 'Type a value in here if it is not included in the list',
    theme: 'bootstrap'
  });
});
