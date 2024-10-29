const currentPage = window.location.pathname.split("/").pop();

let buttons = document.querySelectorAll("li a");



buttons.forEach(link => {
    if(link.getAttribute("href") === currentPage){
        link.classList.add("active")
    }
    
});
