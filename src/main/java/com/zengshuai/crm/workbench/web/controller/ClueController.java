package com.zengshuai.crm.workbench.web.controller;

import com.zengshuai.crm.exception.ConvertException;
import com.zengshuai.crm.settings.domain.User;
import com.zengshuai.crm.utils.DateTimeUtil;
import com.zengshuai.crm.utils.PrintJson;
import com.zengshuai.crm.utils.ServiceFactory;
import com.zengshuai.crm.utils.UUIDUtil;
import com.zengshuai.crm.vo.Pagination;
import com.zengshuai.crm.workbench.domain.Activity;
import com.zengshuai.crm.workbench.domain.Clue;
import com.zengshuai.crm.workbench.domain.Transaction;
import com.zengshuai.crm.workbench.service.ClueService;
import com.zengshuai.crm.workbench.service.impl.ClueServiceImpl;

import javax.servlet.ServletException;
import javax.servlet.ServletRequest;
import javax.servlet.ServletResponse;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

public class ClueController extends HttpServlet {
    @Override
    public void service(ServletRequest req, ServletResponse res) throws ServletException, IOException {
        HttpServletRequest request = (HttpServletRequest)req;
        HttpServletResponse response = (HttpServletResponse)res;
        String path = request.getServletPath();
        if("/workbench/clue/findUsers.do".equals(path)){
            findUsers(request,response);
        }else if("/workbench/clue/disClueList.do".equals(path)){
            disClueList(request,response);
        }else if("/workbench/clue/saveClue.do".equals(path)){
            saveClue(request,response);
        }else if("/workbench/clue/detail.do".equals(path)){
            detail(request,response);
        }else if("/workbench/clue/findActivities.do".equals(path)){
            findActivities(request,response);
        }else if("/workbench/clue/searchActivityByName.do".equals(path)){
            searchActivityByName(request,response);
        }else if("/workbench/clue/bundActivity.do".equals(path)){
            bundActivity(request,response);
        }else if("/workbench/clue/searchActivityOnlyByName.do".equals(path)){
            searchActivityOnlyByName(request,response);
        }else if("/workbench/clue/deleteRelation.do".equals(path)){
            deleteRelation(request,response);
        }else if("/workbench/clue/convert.do".equals(path)){
            convert(request,response);
        }
    }

    private void convert(HttpServletRequest request, HttpServletResponse response) throws IOException {
        ClueService service = (ClueService) ServiceFactory.getService(new ClueServiceImpl());
        String a = request.getParameter("a");
        String clueId = request.getParameter("clueId");
        Transaction transaction = null;
        if("1".equals(a)){
            //要求创建交易,获取交易信息
            transaction = new Transaction();
            String activityId = request.getParameter("activityId");
            String amountOfMoney = request.getParameter("amountOfMoney");
            String tradeName = request.getParameter("tradeName");
            String expectedClosingDate = request.getParameter("expectedClosingDate");
            String stage = request.getParameter("stage");
            String createTime = DateTimeUtil.getSysTime();
            User user = (User)request.getSession().getAttribute("userInfo");
            String createBy = user.getId();
            transaction.setId(UUIDUtil.getUUID());
            transaction.setActivityId(activityId);
            transaction.setMoney(amountOfMoney);
            transaction.setName(tradeName);
            transaction.setExpectedDate(expectedClosingDate);
            transaction.setStage(stage);
            transaction.setCreateTime(createTime);
            transaction.setCreateBy(createBy);
        }
        //交易对象，保存的是交易的内容；线索id，用于查找线索对象；
        try {
            service.convert(transaction,clueId);
            response.sendRedirect(request.getContextPath() + "/workbench/clue/index.jsp");
        } catch (ConvertException e) {
            e.printStackTrace();
            String errorMsg = e.getMessage();
            response.getWriter().write(errorMsg);
        }

    }

    private void deleteRelation(HttpServletRequest request, HttpServletResponse response) {
        ClueService service = (ClueService) ServiceFactory.getService(new ClueServiceImpl());
        String clueId = request.getParameter("clueId");
        String aId = request.getParameter("aId");
        boolean flag = service.deleteRelation(clueId,aId);
        PrintJson.printJsonFlag(response,flag);
    }

    private void searchActivityOnlyByName(HttpServletRequest request, HttpServletResponse response) {
        ClueService service = (ClueService) ServiceFactory.getService(new ClueServiceImpl());
        String aname = request.getParameter("aname");
        List<Activity> aList = service.searchActivityOnlyByName(aname);
        PrintJson.printJsonObj(response,aList);
    }

    private void bundActivity(HttpServletRequest request, HttpServletResponse response) {
        ClueService service = (ClueService) ServiceFactory.getService(new ClueServiceImpl());
        String clueId =request.getParameter("clueId");
        String[] ActivityIds = request.getParameterValues("activityId");
        boolean flag = service.bundActivity(clueId,ActivityIds);
        PrintJson.printJsonFlag(response,flag);
    }

    private void searchActivityByName(HttpServletRequest request, HttpServletResponse response) {
        ClueService service = (ClueService) ServiceFactory.getService(new ClueServiceImpl());
        String aname = request.getParameter("aname");
        String clueId = request.getParameter("clueId");
        List<Activity> aList = service.searchActivityByName(aname,clueId);
        PrintJson.printJsonObj(response,aList);
    }

    private void findActivities(HttpServletRequest request, HttpServletResponse response) {
        ClueService service = (ClueService) ServiceFactory.getService(new ClueServiceImpl());
        String clueId = request.getParameter("id");
        List<Activity> aList = service.findActivities(clueId);
        PrintJson.printJsonObj(response,aList);
    }

    private void detail(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        ClueService service = (ClueService) ServiceFactory.getService(new ClueServiceImpl());
        String id = request.getParameter("id");
        Clue clue = service.getClueById(id);
        request.setAttribute("clueInfo",clue);
        request.getRequestDispatcher("detail.jsp").forward(request,response);
    }

    private void saveClue(HttpServletRequest request, HttpServletResponse response) {
        ClueService service = (ClueService) ServiceFactory.getService(new ClueServiceImpl());
        String id  = UUIDUtil.getUUID();
        User user = (User)request.getSession().getAttribute("userInfo");
        String createBy = user.getId();
        String createTime = DateTimeUtil.getSysTime();

        String fullname = request.getParameter("fullname");
        String appellation = request.getParameter("appellation");
        String owner = request.getParameter("owner");
        String company = request.getParameter("company");
        String job = request.getParameter("job");
        String email = request.getParameter("email");
        String phone = request.getParameter("phone");
        String website = request.getParameter("website");
        String mphone = request.getParameter("mphone");
        String state = request.getParameter("state");
        String source = request.getParameter("source");
        String description = request.getParameter("description");
        String contactSummary = request.getParameter("contactSummary");
        String nextContactTime = request.getParameter("nextContactTime");
        String address = request.getParameter("address");
        Clue clue = new Clue();
        clue.setId(id);
        clue.setCreateBy(createBy);
        clue.setCreateTime(createTime);
        clue.setFullname(fullname);
        clue.setAppellation(appellation);
        clue.setOwner(owner);
        clue.setCompany(company);
        clue.setJob(job);
        clue.setEmail(email);
        clue.setPhone(phone);
        clue.setWebsite(website);
        clue.setMphone(mphone);
        clue.setState(state);
        clue.setSource(source);
        clue.setDescription(description);
        clue.setContactSummary(contactSummary);
        clue.setNextContactTime(nextContactTime);
        clue.setAddress(address);
        boolean flag = service.saveClue(clue);
        PrintJson.printJsonFlag(response,flag);

    }

    private void disClueList(HttpServletRequest request, HttpServletResponse response) {
        ClueService service = (ClueService) ServiceFactory.getService(new ClueServiceImpl());
        int pageNo = Integer.valueOf(request.getParameter("pageNo"));
        int pageSize = Integer.valueOf(request.getParameter("pageSize"));
        String fullname = request.getParameter("name");
        String company = request.getParameter("company");
        String phone = request.getParameter("phone");
        String source = request.getParameter("source");
        String owner = request.getParameter("owner");
        String mphone = request.getParameter("mphone");
        String state = request.getParameter("state");
        int skipPage = (pageNo - 1) * pageSize;

        Map<String,Object> map = new HashMap<>();
        map.put("fullname",fullname);
        map.put("company",company);
        map.put("phone",phone);
        map.put("source",source);
        map.put("owner",owner);
        map.put("mphone",mphone);
        map.put("state",state);
        map.put("pageSize",pageSize);
        map.put("skipPage",skipPage);
        Pagination<Clue> pagination = service.disClueList(map);
        PrintJson.printJsonObj(response,pagination);


    }

    private void findUsers(HttpServletRequest request, HttpServletResponse response) {
        ClueService service = (ClueService) ServiceFactory.getService(new ClueServiceImpl());
        List<User> uList = service.findUsers();
        PrintJson.printJsonObj(response,uList);
    }
}
