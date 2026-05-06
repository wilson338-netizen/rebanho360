document.getElementById("formCliente").addEventListener("submit", async function(e) {
    e.preventDefault();

    const nome = document.getElementById("nome").value;
    const documento = document.getElementById("documento").value;
    const idade = document.getElementById("idade").value;

    const response = await fetch("/clientes", {
        method: "POST",
        headers: {
            "Content-Type": "application/json"
        },
        body: JSON.stringify({ nome, documento, idade })
    });

    if (response.ok) {
        document.getElementById("mensagem").innerText = "Cliente Cadastrado!";
        document.getElementById("formCliente").reset();
    } else {
        document.getElementById("mensagem").innerText = "Erro ao cadastrar.";
    }
});
