jQuery ->
  $('button.reset').on 'click', (event) ->
    event.preventDefault()
    $(@).closest('form').find('input, select').not(':input[type=submit]').val('')
    $('#mailer_action').text('')

  $('#mailer').on 'change', (event) ->
    mailer = $(@).val()
    actionSelect = $('#mailer_action')
    if mailer != ''
      loc = window.location
      port = unless loc.port == 80 then ":#{loc.port}" else ''
      $.post "#{loc.protocol}//#{loc.hostname}#{port}#{loc.pathname}actions", mailer: mailer, (data) ->
        console.log data
        actionSelect.append($('<option></option>').val(action).text(action)) for action in data
    else
      actionSelect.text('')

