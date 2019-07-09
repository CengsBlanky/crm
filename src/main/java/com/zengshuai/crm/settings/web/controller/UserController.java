package com.zengshuai.crm.settings.web.controller;

import com.zengshuai.crm.exception.LoginException;
import com.zengshuai.crm.settings.domain.User;
import com.zengshuai.crm.settings.service.UserService;
import com.zengshuai.crm.settings.service.impl.UserServiceImpl;
import com.zengshuai.crm.utils.PrintJson;
import com.zengshuai.crm.utils.ServiceFactory;

import javax.servlet.ServletException;
import javax.servlet.ServletRequest;
import javax.servlet.ServletResponse;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import java.io.IOException;
import java.util.HashMap;
import java.util.Map;

/**
*function:  -
*project:   crm
*author:    cengs
*version:   1.0 2019/6/29_9:55 
*/
public class UserController extends HttpServlet {
    @Override
    public void service(ServletRequest req, ServletResponse resp) throws ServletException, IOException {
        HttpServletRequest request = (HttpServletRequest)req;
        HttpServletResponse response = (HttpServletResponse)resp;
        String path = request.getServletPath();
        if("/settings/user/login.do".equals(path)){
            login(request,response);
        }
    }

    private void login(HttpServletRequest request, HttpServletResponse response){
        UserService service = (UserService)ServiceFactory.getService(new UserServiceImpl());
        String loginAct = request.getParameter("loginAct");
        String loginPwd = request.getParameter("loginPwd");
        String ip = request.getRemoteAddr();
        HttpSession session = request.getSession();
        try {
            User user = service.login(loginAct,loginPwd,ip);
            session.setAttribute("userInfo",user);
            PrintJson.printJsonFlag(response,true);

        } catch (LoginException e) {
            e.printStackTrace();
            String msg = e.getMessage();
            Map<String,Object> map  = new HashMap<>();
            map.put("success",false);
            map.put("msg",msg);
            PrintJson.printJsonObj(response,map);
        }

    }
}
