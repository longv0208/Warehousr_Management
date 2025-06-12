package controller.dashboard.admin;

import dao.SupplierDAO;
import model.Supplier;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.util.List;

@WebServlet(name = "ManageSupplierController", urlPatterns = {"/admin/manage-supplier"})
public class ManageSupplierController extends HttpServlet {

    private SupplierDAO supplierDAO;

    @Override
    public void init() throws ServletException {
        super.init();
        supplierDAO = new SupplierDAO();
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        String action = request.getParameter("action");
        if (action == null) {
            action = "list"; // Default action
        }

        switch (action) {
            case "list":
                listSuppliers(request, response);
                break;
            case "create":
                showCreateForm(request, response);
                break;
            case "edit":
                showEditForm(request, response);
                break;
            case "delete":
                deleteSupplier(request, response);
                break;
            default:
                listSuppliers(request, response);
                break;
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        String action = request.getParameter("action");
        if (action == null) {
            response.sendRedirect(request.getContextPath() + "/admin/manage-supplier?action=list");
            return;
        }

        switch (action) {
            case "create":
                createSupplier(request, response);
                break;
            case "edit":
                updateSupplier(request, response);
                break;
            default:
                listSuppliers(request, response);
                break;
        }
    }

    private void listSuppliers(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        // Pagination and filtering parameters
        String searchTerm = request.getParameter("search");
        String pageStr = request.getParameter("page");
        int page = (pageStr == null || pageStr.isEmpty()) ? 1 : Integer.parseInt(pageStr);
        int pageSize = 10; // Items per page

        List<Supplier> suppliers = supplierDAO.findSuppliers(searchTerm, page, pageSize);
        int totalSuppliers = supplierDAO.getTotalFilteredSuppliers(searchTerm);
        int totalPages = (int) Math.ceil((double) totalSuppliers / pageSize);

        request.setAttribute("suppliers", suppliers);
        request.setAttribute("currentPage", page);
        request.setAttribute("totalPages", totalPages);
        request.setAttribute("totalSuppliers", totalSuppliers);
        request.setAttribute("searchTerm", searchTerm);

        request.getRequestDispatcher("/view/dashboard/admin/suppliers/supplier.jsp").forward(request, response);
    }

    private void showCreateForm(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        request.getRequestDispatcher("/view/dashboard/admin/suppliers/add-supplier.jsp").forward(request, response);
    }

    private void createSupplier(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        try {
            String supplierName = request.getParameter("supplierName");
            String contactPerson = request.getParameter("contactPerson");
            String phoneNumber = request.getParameter("phoneNumber");
            String email = request.getParameter("email");
            String address = request.getParameter("address");

            // Validation
            StringBuilder errorMessages = new StringBuilder();
            
            if (supplierName == null || supplierName.trim().isEmpty()) {
                errorMessages.append("Tên nhà cung cấp không được để trống. ");
            } else if (supplierName.trim().length() > 100) {
                errorMessages.append("Tên nhà cung cấp không được quá 100 ký tự. ");
            }
            
            if (contactPerson == null || contactPerson.trim().isEmpty()) {
                errorMessages.append("Tên người liên hệ không được để trống. ");
            } else if (contactPerson.trim().length() > 100) {
                errorMessages.append("Tên người liên hệ không được quá 100 ký tự. ");
            }
            
            if (phoneNumber == null || phoneNumber.trim().isEmpty()) {
                errorMessages.append("Số điện thoại không được để trống. ");
            } else if (!phoneNumber.matches("^[0-9]{10,11}$")) {
                errorMessages.append("Số điện thoại phải có 10-11 chữ số. ");
            }
            
            if (email == null || email.trim().isEmpty()) {
                errorMessages.append("Email không được để trống. ");
            } else if (!email.matches("^[A-Za-z0-9+_.-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}$")) {
                errorMessages.append("Email không đúng định dạng. ");
            }
            
            if (address == null || address.trim().isEmpty()) {
                errorMessages.append("Địa chỉ không được để trống. ");
            } else if (address.trim().length() > 255) {
                errorMessages.append("Địa chỉ không được quá 255 ký tự. ");
            }
            
            // Check if supplier name or email already exists
            if (supplierDAO.isSupplierNameExist(supplierName.trim())) {
                errorMessages.append("Tên nhà cung cấp đã tồn tại. ");
            }
            
            if (supplierDAO.isEmailExist(email.trim())) {
                errorMessages.append("Email đã được sử dụng. ");
            }
            
            if (errorMessages.length() > 0) {
                request.getSession().setAttribute("toastMessage", errorMessages.toString());
                request.getSession().setAttribute("toastType", "error");
                response.sendRedirect(request.getContextPath() + "/admin/manage-supplier?action=create");
                return;
            }

            Supplier supplier = Supplier.builder()
                    .supplierName(supplierName.trim())
                    .contactPerson(contactPerson.trim())
                    .phoneNumber(phoneNumber.trim())
                    .email(email.trim())
                    .address(address.trim())
                    .build();

            int generatedId = supplierDAO.insert(supplier);
            if (generatedId > 0) {
                request.getSession().setAttribute("toastMessage", "Nhà cung cấp đã được tạo thành công!");
                request.getSession().setAttribute("toastType", "success");
            } else {
                request.getSession().setAttribute("toastMessage", "Lỗi khi tạo nhà cung cấp.");
                request.getSession().setAttribute("toastType", "error");
            }
        } catch (Exception e) {
            request.getSession().setAttribute("toastMessage", "Đã xảy ra lỗi không mong muốn: " + e.getMessage());
            request.getSession().setAttribute("toastType", "error");
        }
        response.sendRedirect(request.getContextPath() + "/admin/manage-supplier?action=list");
    }

    private void showEditForm(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        try {
            int supplierId = Integer.parseInt(request.getParameter("id"));
            Supplier supplier = supplierDAO.findById(supplierId);
            if (supplier != null) {
                request.setAttribute("supplier", supplier);
                request.getRequestDispatcher("/view/dashboard/admin/suppliers/edit-supplier.jsp").forward(request, response);
            } else {
                request.getSession().setAttribute("toastMessage", "Nhà cung cấp không tồn tại.");
                request.getSession().setAttribute("toastType", "error");
                response.sendRedirect(request.getContextPath() + "/admin/manage-supplier?action=list");
            }
        } catch (NumberFormatException e) {
            request.getSession().setAttribute("toastMessage", "ID nhà cung cấp không hợp lệ.");
            request.getSession().setAttribute("toastType", "error");
            response.sendRedirect(request.getContextPath() + "/admin/manage-supplier?action=list");
        }
    }

    private void updateSupplier(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        try {
            Integer supplierId = Integer.parseInt(request.getParameter("supplierId"));
            String supplierName = request.getParameter("supplierName");
            String contactPerson = request.getParameter("contactPerson");
            String phoneNumber = request.getParameter("phoneNumber");
            String email = request.getParameter("email");
            String address = request.getParameter("address");

            // Validation
            StringBuilder errorMessages = new StringBuilder();
            
            if (supplierName == null || supplierName.trim().isEmpty()) {
                errorMessages.append("Tên nhà cung cấp không được để trống. ");
            } else if (supplierName.trim().length() > 100) {
                errorMessages.append("Tên nhà cung cấp không được quá 100 ký tự. ");
            }
            
            if (contactPerson == null || contactPerson.trim().isEmpty()) {
                errorMessages.append("Tên người liên hệ không được để trống. ");
            } else if (contactPerson.trim().length() > 100) {
                errorMessages.append("Tên người liên hệ không được quá 100 ký tự. ");
            }
            
            if (phoneNumber == null || phoneNumber.trim().isEmpty()) {
                errorMessages.append("Số điện thoại không được để trống. ");
            } else if (!phoneNumber.matches("^[0-9]{10,11}$")) {
                errorMessages.append("Số điện thoại phải có 10-11 chữ số. ");
            }
            
            if (email == null || email.trim().isEmpty()) {
                errorMessages.append("Email không được để trống. ");
            } else if (!email.matches("^[A-Za-z0-9+_.-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}$")) {
                errorMessages.append("Email không đúng định dạng. ");
            }
            
            if (address == null || address.trim().isEmpty()) {
                errorMessages.append("Địa chỉ không được để trống. ");
            } else if (address.trim().length() > 255) {
                errorMessages.append("Địa chỉ không được quá 255 ký tự. ");
            }
            
            // Check if supplier name or email already exists (excluding current supplier)
            Supplier existingByName = supplierDAO.findBySupplierName(supplierName.trim());
            if (existingByName != null && existingByName.getSupplierId() != supplierId) {
                errorMessages.append("Tên nhà cung cấp đã tồn tại. ");
            }
            
            Supplier existingByEmail = supplierDAO.findByEmail(email.trim());
            if (existingByEmail != null && existingByEmail.getSupplierId() != supplierId) {
                errorMessages.append("Email đã được sử dụng. ");
            }
            
            if (errorMessages.length() > 0) {
                request.getSession().setAttribute("toastMessage", errorMessages.toString());
                request.getSession().setAttribute("toastType", "error");
                response.sendRedirect(request.getContextPath() + "/admin/manage-supplier?action=edit&id=" + supplierId);
                return;
            }

            Supplier supplier = Supplier.builder()
                    .supplierId(supplierId)
                    .supplierName(supplierName.trim())
                    .contactPerson(contactPerson.trim())
                    .phoneNumber(phoneNumber.trim())
                    .email(email.trim())
                    .address(address.trim())
                    .build();

            boolean success = supplierDAO.update(supplier);
            if (success) {
                request.getSession().setAttribute("toastMessage", "Nhà cung cấp đã được cập nhật thành công!");
                request.getSession().setAttribute("toastType", "success");
            } else {
                request.getSession().setAttribute("toastMessage", "Lỗi khi cập nhật nhà cung cấp.");
                request.getSession().setAttribute("toastType", "error");
            }
        } catch (NumberFormatException e) {
            request.getSession().setAttribute("toastMessage", "Dữ liệu đầu vào không hợp lệ.");
            request.getSession().setAttribute("toastType", "error");
        } catch (Exception e) {
            request.getSession().setAttribute("toastMessage", "Đã xảy ra lỗi không mong muốn: " + e.getMessage());
            request.getSession().setAttribute("toastType", "error");
        }
        response.sendRedirect(request.getContextPath() + "/admin/manage-supplier?action=list");
    }

    private void deleteSupplier(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        try {
            int supplierId = Integer.parseInt(request.getParameter("id"));
            boolean success = supplierDAO.delete(supplierId);
            if (success) {
                request.getSession().setAttribute("toastMessage", "Nhà cung cấp đã được xóa thành công!");
                request.getSession().setAttribute("toastType", "success");
            } else {
                request.getSession().setAttribute("toastMessage", "Lỗi khi xóa nhà cung cấp.");
                request.getSession().setAttribute("toastType", "error");
            }
        } catch (NumberFormatException e) {
            request.getSession().setAttribute("toastMessage", "ID nhà cung cấp không hợp lệ.");
            request.getSession().setAttribute("toastType", "error");
        }
        response.sendRedirect(request.getContextPath() + "/admin/manage-supplier?action=list");
    }
}
