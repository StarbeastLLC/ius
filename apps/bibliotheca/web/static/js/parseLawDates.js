// Parse law dates with Moment.js
$(function () {
  var reformDate = $('#reform-date').html();
  var reformDateParsed = moment(reformDate, 'MM-DD-YYYY');
  $('#reform-date').text(reformDateParsed);
})
