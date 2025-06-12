package controller.dashboard.admin;

import dao.SettingDAO;
import model.Setting;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.sql.SQLException;
import java.util.List;

@WebServlet(name = "ManageSettingController", urlPatterns = {"/admin/manage-setting"})
public class ManageSettingController extends HttpServlet {
    
    private SettingDAO settingDAO;

    @Override
    public void init() throws ServletException {
        super.init();
        settingDAO = new SettingDAO();
    }
    
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        String action = request.getParameter("action");
        if (action == null) {
            action = "list";
        }
        
        switch (action) {
            case "list":
                listSettings(request, response);
                break;
            case "edit":
                showEditForm(request, response);
                break;
            case "add":
                showAddForm(request, response);
                break;
            default:
                listSettings(request, response);
                break;
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        String action = request.getParameter("action");
        if (action == null) {
            response.sendRedirect(request.getContextPath() + "/admin/manage-setting?action=list");
            return;
        }

        switch (action) {
            case "edit":
                updateSetting(request, response);
                break;
            case "add":
                addSetting(request, response);
                break;
            default:
                listSettings(request, response);
                break;
        }
    }

    private void listSettings(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        List<Setting> settings = settingDAO.findAll();
        request.setAttribute("settings", settings);
        request.getRequestDispatcher("/view/dashboard/admin/setting/setting.jsp").forward(request, response);
    }

    private void showAddForm(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        request.getRequestDispatcher("/view/dashboard/admin/setting/addSetting.jsp").forward(request, response);
    }

    private void showEditForm(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        try {
            int settingId = Integer.parseInt(request.getParameter("id"));
            Setting setting = settingDAO.findById(settingId);
            if (setting != null) {
                request.setAttribute("setting", setting);
                request.getRequestDispatcher("/view/dashboard/admin/setting/editSetting.jsp").forward(request, response);
            } else {
                request.getSession().setAttribute("toastMessage", "Không tìm thấy setting.");
                request.getSession().setAttribute("toastType", "error");
                response.sendRedirect(request.getContextPath() + "/admin/manage-setting?action=list");
            }
        } catch (NumberFormatException e) {
            request.getSession().setAttribute("toastMessage", "ID setting không hợp lệ.");
            request.getSession().setAttribute("toastType", "error");
            response.sendRedirect(request.getContextPath() + "/admin/manage-setting?action=list");
        }
    }

    private void addSetting(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        try {
            String key = request.getParameter("key");
            String value = request.getParameter("value");

            // Validate input
            if (key == null || key.trim().isEmpty()) {
                request.getSession().setAttribute("toastMessage", "Khóa không được để trống.");
                request.getSession().setAttribute("toastType", "error");
                response.sendRedirect(request.getContextPath() + "/admin/manage-setting?action=add");
                return;
            }

            // Check if key already exists
            Setting existingSetting = settingDAO.findByKey(key.trim());
            if (existingSetting != null) {
                request.getSession().setAttribute("toastMessage", "Khóa đã tồn tại.");
                request.getSession().setAttribute("toastType", "error");
                response.sendRedirect(request.getContextPath() + "/admin/manage-setting?action=add");
                return;
            }

            // Create new setting
            Setting newSetting = new Setting();
            newSetting.setKey(key.trim());
            newSetting.setValue(value != null ? value.trim() : "");

            int result = settingDAO.insert(newSetting);
            if (result > 0) {
                request.getSession().setAttribute("toastMessage", "Thêm setting thành công!");
                request.getSession().setAttribute("toastType", "success");
            } else {
                request.getSession().setAttribute("toastMessage", "Lỗi khi thêm setting.");
                request.getSession().setAttribute("toastType", "error");
            }
        } catch (Exception e) {
            request.getSession().setAttribute("toastMessage", "Đã xảy ra lỗi không mong muốn: " + e.getMessage());
            request.getSession().setAttribute("toastType", "error");
        }
        response.sendRedirect(request.getContextPath() + "/admin/manage-setting?action=list");
    }

    private void updateSetting(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        try {
            Integer settingId = Integer.parseInt(request.getParameter("settingId"));
            String value = request.getParameter("value");

            Setting setting = settingDAO.findById(settingId);
            if (setting == null) {
                request.getSession().setAttribute("toastMessage", "Không tìm thấy setting.");
                request.getSession().setAttribute("toastType", "error");
                response.sendRedirect(request.getContextPath() + "/admin/manage-setting?action=list");
                return;
            }

            // Chỉ update value, không thay đổi key
            setting.setValue(value != null ? value.trim() : "");

            boolean success = settingDAO.update(setting);
            if (success) {
                request.getSession().setAttribute("toastMessage", "Cập nhật setting thành công!");
                request.getSession().setAttribute("toastType", "success");
            } else {
                request.getSession().setAttribute("toastMessage", "Lỗi khi cập nhật setting.");
                request.getSession().setAttribute("toastType", "error");
            }
        } catch (NumberFormatException e) {
            request.getSession().setAttribute("toastMessage", "ID setting không hợp lệ.");
            request.getSession().setAttribute("toastType", "error");
        } catch (Exception e) {
            request.getSession().setAttribute("toastMessage", "Đã xảy ra lỗi không mong muốn: " + e.getMessage());
            request.getSession().setAttribute("toastType", "error");
        }
        response.sendRedirect(request.getContextPath() + "/admin/manage-setting?action=list");
    }
}
