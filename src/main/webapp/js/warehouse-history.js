document.addEventListener("DOMContentLoaded", function () {
    // Initialize DataTable with Vietnamese language (no jQuery)
    var historyTable = document.getElementById("historyTable");
    if (historyTable && window.DataTable) {
        new DataTable(historyTable, {
            language: {
                url: "//cdn.datatables.net/plug-ins/1.10.21/i18n/Vietnamese.json"
            },
            order: [[6, "desc"]], // Sort by date descending
            pageLength: 25,
            responsive: true
        });
    }
});
