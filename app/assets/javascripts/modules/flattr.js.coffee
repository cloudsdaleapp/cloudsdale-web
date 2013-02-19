# (->
#   s = document.createElement("script")
#   t = document.getElementsByTagName("script")[0]
#   s.type = "text/javascript"
#   s.async = true
#   s.src = "http://api.flattr.com/js/0.6/load.js?mode=auto"
#   t.parentNode.insertBefore s, t
# )()

# window.Flattr = {

#   flattrButton: (->
#     return '<a class="FlattrButton" style="display:none;" rev="flattr;button:compact;" href="http://www.cloudsdale.org"></a>
#             <noscript>
#               <a href="http://flattr.com/thing/1114225/Cloudsdale" target="_blank">
#                 <img src="http://api.flattr.com/button/flattr-badge-large.png" alt="Flattr this" title="Flattr this" border="0" />
#               </a>
#             </noscript>'
#   )

# }

jQuery.fn.flattrButton = (el,options) ->
  $('script#flattr-sdk').remove()
  $(@)
  .append('<a class="FlattrButton" style="display:none;" rev="flattr;button:compact;" href="http://www.cloudsdale.org"></a>
            <noscript>
              <a href="http://flattr.com/thing/1114225/Cloudsdale" target="_blank">
                <img src="http://api.flattr.com/button/flattr-badge-large.png" alt="Flattr this" title="Flattr this" border="0" />
              </a>
            </noscript>')
  .append("<script type='text/javascript'>(function() {
            var s = document.createElement('script'), t = document.getElementsByTagName('script')[0];
            s.type = 'text/javascript';
            s.async = true;
            s.src = 'https://api.flattr.com/js/0.6/load.js?mode=auto';
            t.parentNode.insertBefore(s, t);
            })();
          </script>")


