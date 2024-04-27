import { ref } from 'vue';

export function useBlur() {
    const isOpac = ref(false);
    let isFocus = false;

    function handleBlur(isCancel) {
        isFocus = false;
    }

    function setBlur() {
        isFocus = !isFocus;
        if (!isFocus) {
            isOpac.value = true;
            setTimeout(() => {
                isOpac.value = false;
                document.activeElement.blur();
            }, 190);
        }
    }

    function closeDropDown(isCloseByClickItems) {
        if (isCloseByClickItems) {
            isFocus = false;
            isOpac.value = true;
            setTimeout(() => {
                isOpac.value = false;
                document.activeElement.blur();
            }, 190);
        }
    }

    return { isOpac, handleBlur, setBlur, closeDropDown };
}
