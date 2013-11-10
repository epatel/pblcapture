# pbl capture

This is the iPhone app for `pblcapture` that will receive the screenshots.

This version uses the new SDK 2.0 javascript bridge. Like before the framebuffer will be sent in a number of chunks to this app which will reassemble them to an image which can be saved to the camera roll.

# Usage 

To use this utility there are a couple of steps to be made. First, add the javascript part below to the `pebble-js-app.js` file (or add one).

<pre>
Pebble.addEventListener("appmessage",
                        function(e) {
                          if (e.payload[1396920900]) { // 'SCRD'
                            var req = new XMLHttpRequest();
                            req.open('POST', "http://127.0.0.1:9898", true);
                            req.send(JSON.stringify(e.payload));
                          }
                        });
</pre>

Then add the files `pblcapture.h` and `pblcapture.c` to the pebble project (find them under `pebble_src` here).

Last add calls to `pbl_capture_init()`, `pbl_capture_send()` and `pbl_capture_deinit()`. See example here https://github.com/epatel/pblindex/blob/master/src/pblindex.c (search for `MAKE_SCREEN_SHOT`)

Place the call to `pbl_capture_init()` after the window has been created. Also if you call `app_message_open()` place this call after that and after registering the callbacks, and give `pbl_capture_init()` true as last parameter. If you are not using `app_message_open()` somewhere (you should also add a `pebble-js-app.js` file) give `pbl_capture_init()` false as the last parameter and it will do the `app_message_open()` for you.

Have fun!
Edward
