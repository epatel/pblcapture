# pbl capture

This is the iPhone app for `pblcapture.c` that will receive the screenshots.

# In the Pebble app

For an example see [https://github.com/epatel/pblindex/blob/capture/src/pblindex.c](https://github.com/epatel/pblindex/blob/capture/src/pblindex.c). You can also find `pblcapture.h` and `pblcapture.c` to be used in the Pebble app there.

Use `PBL_CAPTURE_UUID` for App UUID ie.

    PBL_APP_INFO(PBL_CAPTURE_UUID, // Here
                 "My Watch", "My Name",
                 1, 0,
                 RESOURCE_ID_WATCH_MENU_ICON,
                 APP_INFO_WATCH_FACE);

There is a two step setup

Call `prepare_pbl_capture_main(..)` in `pbl_main(..)`. 

    void pbl_main(void *params) {
        PebbleAppHandlers handlers = {
            .init_handler = &init_handler
        };
    
        prepare_pbl_capture_main(&handlers); // Step one
	
        app_event_loop(params, &handlers);
    }

Call `prepare_pbl_capture_init(..)` in the init handler

    void init_handler(AppContextRef app_ctx) {
        window_init(&window, "My Watch");
        window_stack_push(&window, true);
    
        prepare_pbl_capture_init(app_ctx); // Step two
    }

The first step setup the communication buffers for the remote. The second step adds a timer handler, which will be used to send the screenshot.

When the app is displaying the wanted screenshot call `pbl_capture_send()`. Yeah, you need to be connected and running `pbl capture` on the iPhone.

