package com.zengshuai.crm.web.filter;

import javax.servlet.*;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import java.io.IOException;

public class LoginFilter implements Filter {
    public void doFilter(ServletRequest req, ServletResponse resp, FilterChain chain) throws ServletException, IOException {
        HttpServletRequest request = (HttpServletRequest) req;
        HttpServletResponse response = (HttpServletResponse) resp;
        String path = request.getServletPath();
        HttpSession session = request.getSession(false);
        if("/login.jsp".equals(path) || "/settings/user/login.do".equals(path) || session != null){
        chain.doFilter(req,resp);
        }else{
            response.sendRedirect("login.jsp");
        }

    }


}
