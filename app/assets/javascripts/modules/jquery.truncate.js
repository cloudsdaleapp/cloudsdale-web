(function() {
  var _rtrim = function(s) {
      return s.replace(/\s+$/g, "");
  };

  jQuery.fn.fitsTruncationSpecs = function(content, maxHeight, settings) {
    var itFits, oldHTML, oldText;
    if (settings.html) {
      oldHTML = this.html();
      this.html(content);
      itFits = this.height() <= maxHeight;
      this.html(oldHTML);
    } else {
      oldText = this.text();
      this.text(content);
      itFits = this.height() <= maxHeight;
      this.text(oldText);
    }
    return itFits;
  };
  jQuery.fn.performTruncation = function(text, width, lheight, maxHeight, settings) {
    this.text("");
    var top = text.length, bottom = 0, self = this;
    function _fn(s) {
        if (self.fitsTruncationSpecs(_rtrim(s) + settings.omission , maxHeight, settings)) {
            bottom = s.length;
        } else {
            top = s.length;
        }

        if (top > bottom + 1) {
            return _fn(text.substr(0,(top + bottom)/2));
        }

        return _rtrim(text.substr(0, bottom)) + settings.omission;
    };

    return this[settings.html? 'html': 'text'](_fn(text.substr(0, text.length / 2)));
  };
  jQuery.fn.truncate = function(options) {
    var settings;
    options || (options = {});
    settings = {
      omission: '...',
      rows: 1,
      html: false
    };
    jQuery.extend(settings, options);
    return $.each(this, function(i, el) {
      var lheight, maxHeight, text, width;
      text = $(el).text();
      width = $(el).width();
      lheight = $(el).css('line-height') ? parseInt($(el).css('line-height').match(/\d+/)[0]) : 0;
      maxHeight = lheight * settings.rows;
      if (!$(el).fitsTruncationSpecs(text, maxHeight, settings)) {
        return $(el).performTruncation(text, width, lheight, maxHeight, settings);
      }
    });
  };
}).call(this);
