/// @description tests...

if (!did) exit;

if (GetAsyncKeyState(vk_f7) != 0) {
    window_set_caption(MessageBoxA(0, "my text", "my caption", 6));
}
