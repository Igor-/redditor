do ($ = jQuery)->
  $.redditor = {}
  $.redditor.sliderBlockImagesSortableParams =
    scroll: false
    dropOnEmpty: false
    cursor: "crosshair"
    opacity: 0.75
    items: "li"
    update: ->
      self = $(@)
      $.ajax
        data: self.sortable('serialize') + '&authenticity_token=#{u(form_authenticity_token)}'
        dataType: 'script'
        url: self.data("sortable-url")
      .done ->
        return
      .error ->
        alert "Ошибка, данные не сохранены"

  $.redditor.parameterizationForm = (box) ->
    form = box.serializeForm()
    formName = box.find("div.redditor__form").data("object-name")
    firstProperty = formName.replace(/^(.*?)\[.*/,"$1")
    nextProperties = formName.match(/\[(.*?)\]/g)
    nextProperties = $.map nextProperties, (n)->
      n.replace(/\[(.*)\]/,"$1")
    params = form[firstProperty]
    for i in nextProperties
      params = params[i]
    params = "content_block": params

  $.redditor.setPositions = ->
    $el = $.redditor.$el
    $el.find($el.sortable("option", "items")).each (i) ->
      $(@).find("input.redditor__position").val i

  $.redditor.sortList = ->
    sortArray = $.map $.redditor.$el.find("dd"), (n) ->
      key = $(n).attr("class")
      input = $(n).find("input[type=hidden][name='#{$(n).find("div.redditor__form").data("object-name")}[id]']")
      value = input.val()
      if value?
        obj = {}
        obj[key] =
          index: value
          position: $(n).index()      
        obj
      else
        null

    if sortArray.length
      $.ajax
        type: "post"
        # data: self.sortable('serialize') + '&authenticity_token=<%= u(form_authenticity_token) %>',
        data: {sort: sortArray}
        dataType: "script"
        url: $.redditor.$el.data("sort-url")
      .done($.redditor.setPositions)
    else
      $.redditor.setPositions()

#! jquery-serializeForm - Make an object out of form elements - v1.1.1 - 2013-01-21
#* https://github.com/danheberden/jquery-serializeForm
#* Copyright (c) 2013 Dan Heberden; Licensed MIT 
do ($ = jQuery) ->
  $.fn.serializeForm = ->
    
    # don't do anything if we didn't get any elements
    return false  if @length < 1
    data = {}
    lookup = data #current reference of data
    selector = ":input[type!=\"checkbox\"][type!=\"radio\"], input:checked"
    parse = ->
      
      # data[a][b] becomes [ data, a, b ]
      named = @name.replace(/\[([^\]]+)?\]/g, ",$1").split(",")
      cap = named.length - 1
      $el = $(this)
      
      # Ensure that only elements with valid `name` properties will be serialized
      if named[0]
        i = 0

        while i < cap
          
          # move down the tree - create objects or array if necessary
          lookup = lookup[named[i]] = lookup[named[i]] or ((if named[i + 1] is "" then [] else {}))
          i++
        
        # at the end, push or assign the value
        if lookup.length isnt `undefined`
          lookup.push $el.val()
        else
          lookup[named[cap]] = $el.val()
        
        # assign the reference back to root
        lookup = data

    
    # first, check for elements passed into this function
    @filter(selector).each parse
    
    # then parse possible child elements
    @find(selector).each parse
    
    # return data
    data

$ ->
  $.redditor.$el = $("#redditor")

  # $(".add_fields").click ->
  #   time = new Date().getTime()
  #   regexp = new RegExp($(this).data("id"), "g")
  #   self = $.redditor.$el.append($(this).data("fields").replace(regexp, time))
  #   $.redditor.setPositions()

  $.redditor.$el.sortable
    dropOnEmpty: false
    cursor: "crosshair"
    opacity: 0.75
    handle: ".redditor__handle"
    axis: "y"
    items: "dd"
    scroll: false
    update: $.redditor.sortList
    start: ->
      # необходимо обновить, чтобы сортировака работала корректно, тк меняем высоту блоков
      $(@).addClass("redditor_sortable").sortable( "refresh" )
      return
    stop: ->
      $(@).removeClass("redditor_sortable")
      return

  .on "click", "a.redditor__update", (event) ->
    event.preventDefault()
    box = $(@).closest "dd"
    params = $.redditor.parameterizationForm(box)
    if params.content_block.id
      $.extend params, _method: 'patch'
    $.ajax
      method: 'POST',
      url: this.href,
      data: params

  $("ul.slider-block-images").sortable $.redditor.sliderBlockImagesSortableParams

  $('div.redditor__add-blocks').on "ajax:beforeSend", "a.redditor__add", (event, xhr, status) ->
    status.url += "?" + $.param(content_block: {temp_id: new Date().getTime()}) # generate uniq id