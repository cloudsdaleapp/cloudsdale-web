clientSideValidations.validators.remote["user_global_uniqueness"] = (element, options) ->
  
  options.message if $.ajax(
      url: "/validators/user_global_uniqueness.json"
    
      data:
        value: element.val()
        user_id: element.attr('user_id')
        attribute_name: element.attr('attribute_name')
      
      async: false
    
    ).status == 404