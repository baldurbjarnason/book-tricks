document.querySelectorAll("img[loading='lazy']").forEach((node) => {
  node.removeAttribute("loading");
});

const link = document.createElement("link");
link.rel = "stylesheet";
link.type = "text/css";
link.href = "../styles/paged.css";
document.head.appendChild(link);

let counter = 0;
document.querySelectorAll("h1,h2").forEach((node) => {
  if (!node.id) {
    counter = counter + 1;
    node.id = `id${counter}`;
  }
});
