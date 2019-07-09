package com.zengshuai.crm.workbench.web.controller;

import com.zengshuai.crm.settings.domain.User;
import com.zengshuai.crm.utils.DateTimeUtil;
import com.zengshuai.crm.utils.PrintJson;
import com.zengshuai.crm.utils.ServiceFactory;
import com.zengshuai.crm.utils.UUIDUtil;
import com.zengshuai.crm.vo.Pagination;
import com.zengshuai.crm.workbench.domain.Activity;
import com.zengshuai.crm.workbench.domain.ActivityRemark;
import com.zengshuai.crm.workbench.service.ActivityService;
import com.zengshuai.crm.workbench.service.impl.ActivityServiceImpl;

import javax.servlet.ServletException;
import javax.servlet.ServletRequest;
import javax.servlet.ServletResponse;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import java.io.IOException;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

public class ActivityController extends HttpServlet {
    @Override
    public void service(ServletRequest req, ServletResponse resp) throws ServletException, IOException {
        HttpServletRequest request = (HttpServletRequest)req;
        HttpServletResponse response = (HttpServletResponse)resp;
        String path = request.getServletPath();
        if("/workbench/activity/findUsers.do".equals(path)){
            findUsers(request,response);
        }else if("/workbench/activity/saveActivity.do".equals(path)){
            saveActivity(request,response);
        }else if("/workbench/activity/showActivityList.do".equals(path)){
            showActivityList(request,response);
        }else if("/workbench/activity/deleteActivity.do".equals(path)){
            deleteActivity(request,response);
        }else if("/workbench/activity/findUsersAndActivities.do".equals(path)){
            findUsersAndActivities(request,response);
        }else if("/workbench/activity/updateActivity.do".equals(path)){
            updateActivity(request,response);
        }else if("/workbench/activity/detailDisplay.do".equals(path)){
            detailDisplay(request,response);
        }else if("/workbench/activity/activityRemark.do".equals(path)){
            activityRemark(request,response);
        }else if("/workbench/activity/saveRemark.do".equals(path)){
            saveRemark(request,response);
        }else if("/workbench/activity/deleteRemark.do".equals(path)){
            deleteRemark(request,response);
        }else if("/workbench/activity/editRemark.do".equals(path)){
            editRemark(request,response);
        }
    }

    private void editRemark(HttpServletRequest request, HttpServletResponse response) {
        ActivityService service = (ActivityService) ServiceFactory.getService(new ActivityServiceImpl());
        String noteContent = request.getParameter("noteContent");
        String id = request.getParameter("id");
        String editBy = request.getParameter("editBy");
        String editTime = DateTimeUtil.getSysTime();
        ActivityRemark remark = new ActivityRemark();
        remark.setId(id);
        remark.setEditFlag("1");
        remark.setEditBy(editBy);
        remark.setEditTime(editTime);
        remark.setNoteContent(noteContent);
        Map<String,Object> map = new HashMap<>();
        map.put("remark",remark);
        boolean flag = service.editRemark(remark);
        map.put("success",flag);
        PrintJson.printJsonObj(response,map);
    }

    private void deleteRemark(HttpServletRequest request, HttpServletResponse response) {
        ActivityService service = (ActivityService) ServiceFactory.getService(new ActivityServiceImpl());
        String id = request.getParameter("id");
        boolean flag = service.deleteRemark(id);
        PrintJson.printJsonFlag(response,flag);
    }

    private void saveRemark(HttpServletRequest request, HttpServletResponse response) {
        ActivityService service = (ActivityService) ServiceFactory.getService(new ActivityServiceImpl());
        String noteContent = request.getParameter("noteContent");
        String createBy = request.getParameter("createBy");
        String activityId = request.getParameter("activityId");
        String id = UUIDUtil.getUUID();
        String createTime = DateTimeUtil.getSysTime();
        String editFlag = "0";
        ActivityRemark remark = new ActivityRemark();
        remark.setId(id);
        remark.setNoteContent(noteContent);
        remark.setCreateTime(createTime);
        remark.setCreateBy(createBy);
        remark.setEditFlag(editFlag);
        remark.setActivityId(activityId);
        Map<String,Object> map = new HashMap<>();
        map.put("activityRemark",remark);
        boolean flag = service.saveRemark(remark);
        map.put("success",flag);
        PrintJson.printJsonObj(response,map);
    }

    private void activityRemark(HttpServletRequest request, HttpServletResponse response) {
        String activityId = request.getParameter("activityId");
        ActivityService service = (ActivityService) ServiceFactory.getService(new ActivityServiceImpl());
        List<ActivityRemark> arList = service.activityRemark(activityId);
        PrintJson.printJsonObj(response,arList);
    }

    private void detailDisplay(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException{
        String activityId = request.getParameter("activityId");
        ActivityService service = (ActivityService) ServiceFactory.getService(new ActivityServiceImpl());
        Activity activity = service.detailDisplay(activityId);
        request.setAttribute("activityDetail",activity);
        request.getRequestDispatcher("detail.jsp").forward(request,response);
    }

    private void updateActivity(HttpServletRequest request, HttpServletResponse response) {
        String editTime = DateTimeUtil.getSysTime();
        String editBy = request.getParameter("editBy");
        String id = request.getParameter("id");
        String owner = request.getParameter("owner");
        String name = request.getParameter("name");
        String startDate = request.getParameter("startDate");
        String endDate = request.getParameter("endDate");
        String cost = request.getParameter("cost");
        String description = request.getParameter("description");
        Activity activity = new Activity();
        activity.setId(id);
        activity.setOwner(owner);
        activity.setName(name);
        activity.setStartDate(startDate);
        activity.setEndDate(endDate);
        activity.setCost(cost);
        activity.setDescription(description);
        activity.setEditBy(editBy);
        activity.setEditTime(editTime);
        ActivityService service = (ActivityService) ServiceFactory.getService(new ActivityServiceImpl());
        boolean flag = service.updateActivity(activity);
        PrintJson.printJsonFlag(response,flag);
    }

    private void findUsersAndActivities(HttpServletRequest request, HttpServletResponse response) {
        String activityId = request.getParameter("activityId");
        ActivityService service = (ActivityService)ServiceFactory.getService(new ActivityServiceImpl());
        Map<String,Object> map = service.findUsersAndActivities(activityId);
        PrintJson.printJsonObj(response,map);
    }

    private void deleteActivity(HttpServletRequest request, HttpServletResponse response) {
        String[] ids = request.getParameterValues("id");
        ActivityService service = (ActivityService)ServiceFactory.getService(new ActivityServiceImpl());
        boolean flag = service.deleteActivity(ids);
        if(flag){
            PrintJson.printJsonFlag(response,true);
        }else{
            PrintJson.printJsonFlag(response,false);
        }
    }

    private void showActivityList(HttpServletRequest request, HttpServletResponse response) {
        int pageNo = Integer.valueOf(request.getParameter("pageNo"));
        int pageSize = Integer.valueOf(request.getParameter("pageSize"));
        String name = request.getParameter("name");
        String owner = request.getParameter("owner");
        String startDate = request.getParameter("startDate");
        String endDate = request.getParameter("endDate");
        Map<String,Object> map = new HashMap<>();
        int skipPage = (pageNo-1) * pageSize;
        map.put("skipPage",skipPage);
        map.put("pageSize",pageSize);
        map.put("name",name);
        map.put("owner",owner);
        map.put("startDate",startDate);
        map.put("endDate",endDate);
        ActivityService service = (ActivityService) ServiceFactory.getService(new ActivityServiceImpl());
        Pagination pagination = service.showActivityList(map);
        PrintJson.printJsonObj(response,pagination);
    }

    private void findUsers(HttpServletRequest request,HttpServletResponse response){
        ActivityService service =(ActivityService)ServiceFactory.getService(new ActivityServiceImpl());
        PrintJson.printJsonObj(response,service.FindUsers());
    }

    private void saveActivity(HttpServletRequest request,HttpServletResponse response){
        HttpSession session = request.getSession(false);
        User user = (User)session.getAttribute("userInfo");
        String owner = request.getParameter("owner");
        String name = request.getParameter("name");
        String startDate = request.getParameter("startDate");
        String endDate = request.getParameter("endDate");
        String cost = request.getParameter("cost");
        String description = request.getParameter("description");
        String id = UUIDUtil.getUUID();
        String createTime = DateTimeUtil.getSysTime();
        String createBy = user.getName();
        Activity activity = new Activity();
        activity.setId(id);
        activity.setOwner(owner);
        activity.setName(name);
        activity.setStartDate(startDate);
        activity.setEndDate(endDate);
        activity.setCost(cost);
        activity.setDescription(description);
        activity.setCreateTime(createTime);
        activity.setCreateBy(createBy);
        ActivityService service = (ActivityService)ServiceFactory.getService(new ActivityServiceImpl());
        int flag = service.SaveActivity(activity);
        if(flag != 1){
            PrintJson.printJsonFlag(response,false);
        }else{
            PrintJson.printJsonFlag(response,true);
        }
    }
}
