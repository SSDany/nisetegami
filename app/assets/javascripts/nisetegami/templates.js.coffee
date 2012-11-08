jQuery ->
  $('button.reset').on 'click', (event) ->
    event.preventDefault()
    $(@).closest('form').find('input, select').not(':input[type=submit]').val('')
    $('#action').text('')

  $('#mailer').on 'change', (event) ->
    mailer = $(@).val()
    actionSelect = $('#mailer_action')
    if mailer != ''
      $.post "#{window.location}/actions", mailer: mailer, (data) ->
        actionSelect.append($('<option></option>').val(action).text(action)) for action in data
    else
      actionSelect.text('')

