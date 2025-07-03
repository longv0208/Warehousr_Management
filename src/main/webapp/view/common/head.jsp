<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1">
<!-- Bootstrap & Icons -->
<link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet" />
<link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.10.5/font/bootstrap-icons.css" rel="stylesheet" />
<style>
    body {
        display: flex;
        min-height: 100vh;
        flex-direction: column;
    }
    .main-content {
        flex: 1;
    }
    .sidebar {
        width: 280px;
        background: #f8f9fa;
        height: 100vh;
        position: fixed;
        top: 0;
        left: 0;
    }
    .content-wrapper {
        margin-left: 280px;
        width: calc(100% - 280px);
    }
</style> 