jQuery ->
  $('button.reset').on 'click', (event) ->
    event.preventDefault()
    $(@).closest('form').find('input, select').not(':input[type=submit]').val('')
    $('#mailer_action').text('')

  $('#mailer').on 'change', (event) ->
    mailer = $(@).val()
    actionSelect = $('#mailer_action')
    if mailer != ''
      location = window.location
      port = unless location.port == 80 then ":#{location.port}" else ''
      $.post "#{location.protocol}//#{location.hostname}#{port}#{location.pathname}/actions", mailer: mailer, (data) ->
        actionSelect.append($('<option></option>').val(action).text(action)) for action in data
    else
      actionSelect.text('')

