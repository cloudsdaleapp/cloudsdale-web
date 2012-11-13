/**
    window.resizeStop emulates a "resizestop" event on the window object.

    This is useful for performing actions that depend on the window size, but are expensive in one way or another - i.e. heavy DOM manipulation or asset loading that might be detrimental to performance if run as often as resize events can fire.

    The library-agnostic version assumes the best-case - full support for a number of methods that older or non-DOM-compliant browsers may not support.

    Support for the following is assumed:

        Date.now()
        Array.prototype.indexOf()
        window.addEventListener()
 
    You may need to tweak this to work cross-browser or with your library or existing application.

    @name window.resizeStop
    @namespace
*/
(function (window, setTimeout, Date) {

    var cache = [],
        last = 0,
        timer = 0,
        threshold = 500;

    window.addEventListener('resize', function () {
        last = Date.now();
        timer = timer || setTimeout(checkTime, 10);
    }, false);

    window.resizeStop = {

        /**
            Changes the threshold at which {@link checkTime} determines that a resize has stopped.
            
            @param {Number} ms
                A new threshold in milliseconds. Must be finite, greater than
                zero, and not NaN.
            @returns {Number|Boolean}
                Returns the new threshold or false if it failed.
        */
        setThreshold: function (ms) {
            if (typeof ms === 'number' && ms > -1 && !isNaN(ms) && isFinite(ms)) {
                threshold = ms;
                return ms;
            }
            return false;
        },

        /**
            Fires one or more callbacks when it looks like the user has stopped resizing the window.

            @param {Function} callback
                A function to fire when the user stops resizing the window.
            @returns {Number|Boolean}
                Either the index of the callback in the cache or Boolean false (if the callback was not a function).
        */
        bind: function (callback) {
            if (typeof callback === 'function') {
                cache.push(callback);
                return cache.length - 1;
            }
            return false;
        },

        /**
            Removes a callback from the cache. Can either be a pointer to a function or a cache index from {@see window.bindResizeStop}.

            @param {Number|Function} what
                If a number, assumed to be an index in the cache. Otherwise, the cache is searched for the presence of the passed-in value.
            @returns {Boolean}
                Whether or not {@see what} was found in the cache.
        */
        unbind: function (what) {
            // Assumes support for Array.prototype.indexOf.
            var i = (typeof what === 'number') ? what : cache.indexOf(what);
            if (i > -1) {
                cache.splice(what, 1);
            }
            return i > -1;
        }
    };

    /**
        Checks if the last window resize was over 500ms ago. If so, executes all the functions in the cache.
         
        @private
    */
    function checkTime() {
        var now = Date.now();
        if (now - last < threshold) {
            timer = setTimeout(checkTime, 10);
        } else {
            clearTimeout(timer);
            timer = last = 0;
            for (var i = 0, max = cache.length; i < max; i++) {
                cache[i]();
            }
        }
    }

})(window, setTimeout, Date);


/**

    A jQuery version of window.resizeStop.

    This creates a jQuery special event called "resizestop". This event fires after a certain number of milliseconds since the last resize event fired.

    Additionally, as part of the event data that gets passed to the eventual handler function, the resizestop special event passes the size of the window in an object called "size".

    For example:

    $(window).bind('resizestop', function (e) {
        console.log(e.data.size);
    });

    This is useful for performing actions that depend on the window size, but are expensive in one way or another - i.e. heavy DOM manipulation or asset loading that might be detrimental to performance if run as often as resize events can fire.

    @name jQuery.event.special.resizestop
    @requires jQuery 1.4.2
    @namespace

*/
(function ($, setTimeout) {

    var $window = $(window),
        cache = $([]),
        last = 0,
        timer = 0,
        size = {};

    /**
        Handles window resize events.

        @private
        @ignore
    */
    function onWindowResize() {
        last = $.now();
        timer = timer || setTimeout(checkTime, 10);
    }

    /**
        Checks if the last window resize was over the threshold. If so, executes all the functions in the cache.

        @private
        @ignore
    */
    function checkTime() {
        var now = $.now();
        if (now - last < $.resizestop.threshold) {
            timer = setTimeout(checkTime, 10);
        } else {
            clearTimeout(timer);
            timer = last = 0;
            size.width = $window.width();
            size.height = $window.height();
            cache.trigger('resizestop');
        }
    }

    /**
        Contains configuration settings for resizestop events.

        @namespace
    */
    $.resizestop = {
        propagate: false,
        threshold: 500
    };

    /**
        Contains helper methods used by the jQuery special events API.

        @namespace
        @ignore
    */
    $.event.special.resizestop = {
        setup: function (data, namespaces) {
            cache = cache.not(this); // Prevent duplicates.
            cache = cache.add(this);
            if (cache.length === 1) {
                $window.bind('resize', onWindowResize);
            }
        },
        teardown: function (namespaces) {
            cache = cache.not(this);
            if (!cache.length) {
                $window.unbind('resize', onWindowResize);
            }
        },
        add: function (handle) {
            var oldHandler = handle.handler;
            handle.handler = function (e) {
                // Generally, we don't want this to propagate.
                if (!$.resizestop.propagate) {
                    e.stopPropagation();
                }
                e.data = e.data || {};
                e.data.size = e.data.size || {};
                $.extend(e.data.size, size);
                return oldHandler.apply(this, arguments);
            };
        }
    };

})(jQuery, setTimeout);