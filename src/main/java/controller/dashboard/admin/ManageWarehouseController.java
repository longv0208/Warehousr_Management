package controller.dashboard.admin;

import dao.WarehouseDAO;
import model.Warehouse;
import model.User;
import utils.SessionUtil;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.util.List;

@WebServlet(name = "ManageWarehouseController", urlPatterns = {"/admin/manage-warehouse"})
public class ManageWarehouseController extends HttpServlet {

    private WarehouseDAO warehouseDAO;

    @Override
    public void init() throws ServletException {
        super.init();
        warehouseDAO = new WarehouseDAO();
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        // Check if user is logged in
        User currentUser = SessionUtil.getUserFromSession(request);
        if (currentUser == null) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }

        String action = request.getParameter("action");
        if (action == null) {
            action = "list"; // Default action
        }

        // Check permissions for admin-only actions
        if (!action.equals("list") && !"admin".equals(currentUser.getRoleId())) {
            request.getSession().setAttribute("toastMessage", "Bạn không có quyền thực hiện thao tác này!");
            request.getSession().setAttribute("toastType", "error");
            response.sendRedirect(request.getContextPath() + "/admin/manage-warehouse?action=list");
            return;
        }

        switch (action) {
            case "list":
                listWarehouses(request, response);
                break;
            case "create":
                showCreateForm(request, response);
                break;
            case "edit":
                showEditForm(request, response);
                break;
            case "delete":
                deleteWarehouse(request, response);
                break;
            default:
                listWarehouses(request, response);
                break;
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        // Check if user is logged in and is admin
        User currentUser = SessionUtil.getUserFromSession(request);
        if (currentUser == null) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }

        if (!"admin".equals(currentUser.getRoleId())) {
            request.getSession().setAttribute("toastMessage", "Bạn không có quyền thực hiện thao tác này!");
            request.getSession().setAttribute("toastType", "error");
            response.sendRedirect(request.getContextPath() + "/admin/manage-warehouse?action=list");
            return;
        }

        String action = request.getParameter("action");
        if (action == null) {
            response.sendRedirect(request.getContextPath() + "/admin/manage-warehouse?action=list");
            return;
        }

        switch (action) {
            case "create":
                createWarehouse(request, response);
                break;
            case "edit":
                updateWarehouse(request, response);
                break;
            default:
                listWarehouses(request, response);
                break;
        }
    }

    private void listWarehouses(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        String searchTerm = request.getParameter("search");
        List<Warehouse> warehouses;
        
        if (searchTerm != null && !searchTerm.trim().isEmpty()) {
            warehouses = warehouseDAO.searchWarehouses(searchTerm.trim());
        } else {
            warehouses = warehouseDAO.findAll();
        }
        
        // Get current user for permission checking in JSP
        User currentUser = SessionUtil.getUserFromSession(request);
        String userRole = (currentUser != null) ? currentUser.getRoleId() : "";
        
        request.setAttribute("warehouses", warehouses);
        request.setAttribute("searchTerm", searchTerm);
        request.setAttribute("userRole", userRole);
        request.getRequestDispatcher("/view/dashboard/admin/warehouse/warehouse.jsp").forward(request, response);
    }

    private void showCreateForm(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        request.getRequestDispatcher("/view/dashboard/admin/warehouse/addWarehouse.jsp").forward(request, response);
    }

    private void createWarehouse(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        String warehouseName = request.getParameter("warehouseName");
        String address = request.getParameter("address");

        // Validation
        if (warehouseName == null || warehouseName.trim().isEmpty()) {
            request.setAttribute("error", "Tên kho hàng không được để trống!");
            request.getRequestDispatcher("/view/dashboard/admin/warehouse/addWarehouse.jsp").forward(request, response);
            return;
        }

        if (address == null || address.trim().isEmpty()) {
            request.setAttribute("error", "Địa chỉ không được để trống!");
            request.getRequestDispatcher("/view/dashboard/admin/warehouse/addWarehouse.jsp").forward(request, response);
            return;
        }

        // Check if warehouse name already exists
        if (warehouseDAO.isWarehouseNameExists(warehouseName.trim())) {
            request.setAttribute("error", "Tên kho hàng đã tồn tại!");
            request.setAttribute("warehouseName", warehouseName);
            request.setAttribute("address", address);
            request.getRequestDispatcher("/view/dashboard/admin/warehouse/addWarehouse.jsp").forward(request, response);
            return;
        }

        Warehouse warehouse = new Warehouse();
        warehouse.setWarehouseName(warehouseName.trim());
        warehouse.setAddress(address.trim());

        int result = warehouseDAO.insert(warehouse);
        if (result > 0) {
            request.getSession().setAttribute("toastMessage", "Thêm kho hàng thành công!");
            request.getSession().setAttribute("toastType", "success");
            response.sendRedirect(request.getContextPath() + "/admin/manage-warehouse?action=list");
        } else {
            request.setAttribute("error", "Có lỗi xảy ra khi thêm kho hàng!");
            request.setAttribute("warehouseName", warehouseName);
            request.setAttribute("address", address);
            request.getRequestDispatcher("/view/dashboard/admin/warehouse/addWarehouse.jsp").forward(request, response);
        }
    }

    private void showEditForm(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        String idStr = request.getParameter("id");
        if (idStr == null || idStr.isEmpty()) {
            response.sendRedirect(request.getContextPath() + "/admin/manage-warehouse?action=list");
            return;
        }

        try {
            int warehouseId = Integer.parseInt(idStr);
            Warehouse warehouse = warehouseDAO.findById(warehouseId);
            if (warehouse == null) {
                request.getSession().setAttribute("toastMessage", "Không tìm thấy kho hàng!");
                request.getSession().setAttribute("toastType", "error");
                response.sendRedirect(request.getContextPath() + "/admin/manage-warehouse?action=list");
                return;
            }

            request.setAttribute("warehouse", warehouse);
            request.getRequestDispatcher("/view/dashboard/admin/warehouse/edit-warehouse.jsp").forward(request, response);
        } catch (NumberFormatException e) {
            response.sendRedirect(request.getContextPath() + "/admin/manage-warehouse?action=list");
        }
    }

    private void updateWarehouse(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        String idStr = request.getParameter("warehouseId");
        String warehouseName = request.getParameter("warehouseName");
        String address = request.getParameter("address");

        if (idStr == null || idStr.isEmpty()) {
            response.sendRedirect(request.getContextPath() + "/admin/manage-warehouse?action=list");
            return;
        }

        try {
            int warehouseId = Integer.parseInt(idStr);
            Warehouse currentWarehouse = warehouseDAO.findById(warehouseId);
            
            if (currentWarehouse == null) {
                request.getSession().setAttribute("toastMessage", "Không tìm thấy kho hàng!");
                request.getSession().setAttribute("toastType", "error");
                response.sendRedirect(request.getContextPath() + "/admin/manage-warehouse?action=list");
                return;
            }

            // Validation
            if (warehouseName == null || warehouseName.trim().isEmpty()) {
                request.setAttribute("error", "Tên kho hàng không được để trống!");
                request.setAttribute("warehouse", currentWarehouse);
                request.getRequestDispatcher("/view/dashboard/admin/warehouse/edit-warehouse.jsp").forward(request, response);
                return;
            }

            if (address == null || address.trim().isEmpty()) {
                request.setAttribute("error", "Địa chỉ không được để trống!");
                request.setAttribute("warehouse", currentWarehouse);
                request.getRequestDispatcher("/view/dashboard/admin/warehouse/edit-warehouse.jsp").forward(request, response);
                return;
            }

            // Check if warehouse name already exists (excluding current warehouse)
            if (warehouseDAO.isWarehouseNameExistsExcluding(warehouseName.trim(), warehouseId)) {
                request.setAttribute("error", "Tên kho hàng đã tồn tại!");
                currentWarehouse.setWarehouseName(warehouseName);
                currentWarehouse.setAddress(address);
                request.setAttribute("warehouse", currentWarehouse);
                request.getRequestDispatcher("/view/dashboard/admin/warehouse/edit-warehouse.jsp").forward(request, response);
                return;
            }

            Warehouse warehouse = new Warehouse();
            warehouse.setWarehouseId(warehouseId);
            warehouse.setWarehouseName(warehouseName.trim());
            warehouse.setAddress(address.trim());

            boolean result = warehouseDAO.update(warehouse);
            if (result) {
                request.getSession().setAttribute("toastMessage", "Cập nhật kho hàng thành công!");
                request.getSession().setAttribute("toastType", "success");
                response.sendRedirect(request.getContextPath() + "/admin/manage-warehouse?action=list");
            } else {
                request.setAttribute("error", "Có lỗi xảy ra khi cập nhật kho hàng!");
                request.setAttribute("warehouse", warehouse);
                request.getRequestDispatcher("/view/dashboard/admin/warehouse/edit-warehouse.jsp").forward(request, response);
            }
        } catch (NumberFormatException e) {
            response.sendRedirect(request.getContextPath() + "/admin/manage-warehouse?action=list");
        }
    }

    private void deleteWarehouse(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        String idStr = request.getParameter("id");
        if (idStr == null || idStr.isEmpty()) {
            response.sendRedirect(request.getContextPath() + "/admin/manage-warehouse?action=list");
            return;
        }

        try {
            int warehouseId = Integer.parseInt(idStr);
            Warehouse warehouse = warehouseDAO.findById(warehouseId);
            
            if (warehouse == null) {
                request.getSession().setAttribute("toastMessage", "Không tìm thấy kho hàng!");
                request.getSession().setAttribute("toastType", "error");
                response.sendRedirect(request.getContextPath() + "/admin/manage-warehouse?action=list");
                return;
            }

            // Check if warehouse is being used in inventory or other relations
            if (warehouseDAO.isWarehouseInUse(warehouseId)) {
                request.getSession().setAttribute("toastMessage", "Không thể xóa kho hàng này vì đang được sử dụng trong hệ thống!");
                request.getSession().setAttribute("toastType", "error");
                response.sendRedirect(request.getContextPath() + "/admin/manage-warehouse?action=list");
                return;
            }

            boolean result = warehouseDAO.delete(warehouse);
            if (result) {
                request.getSession().setAttribute("toastMessage", "Xóa kho hàng thành công!");
                request.getSession().setAttribute("toastType", "success");
            } else {
                request.getSession().setAttribute("toastMessage", "Có lỗi xảy ra khi xóa kho hàng!");
                request.getSession().setAttribute("toastType", "error");
            }
        } catch (NumberFormatException e) {
            request.getSession().setAttribute("toastMessage", "ID kho hàng không hợp lệ!");
            request.getSession().setAttribute("toastType", "error");
        }
        
        response.sendRedirect(request.getContextPath() + "/admin/manage-warehouse?action=list");
    }
} 