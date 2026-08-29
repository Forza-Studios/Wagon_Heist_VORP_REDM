window.addEventListener('message', function(event) {
    var data = event.data;
    if (data.action === "showLoading") {
        var container = document.getElementById("loading-container");
        container.classList.remove("hidden");
        // Force reflow
        void container.offsetWidth;
        container.classList.add("visible");
    } else if (data.action === "hideLoading") {
        var container = document.getElementById("loading-container");
        container.classList.remove("visible");
        setTimeout(function() {
            container.classList.add("hidden");
        }, 500); // match CSS transition duration
    }
});
