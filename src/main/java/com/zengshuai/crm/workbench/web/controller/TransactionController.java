package com.zengshuai.crm.workbench.web.controller;

import com.zengshuai.crm.settings.domain.User;
import com.zengshuai.crm.utils.DateTimeUtil;
import com.zengshuai.crm.utils.PrintJson;
import com.zengshuai.crm.utils.ServiceFactory;
import com.zengshuai.crm.utils.UUIDUtil;
import com.zengshuai.crm.vo.Pagination;
import com.zengshuai.crm.workbench.domain.Activity;
import com.zengshuai.crm.workbench.domain.Contacts;
import com.zengshuai.crm.workbench.domain.TranHistory;
import com.zengshuai.crm.workbench.domain.Transaction;
import com.zengshuai.crm.workbench.service.TransactionService;
import com.zengshuai.crm.workbench.service.impl.TransactionServiceImpl;


import javax.print.attribute.standard.JobKOctets;
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

public class TransactionController extends HttpServlet {
    @Override
    public void service(ServletRequest req, ServletResponse res) throws ServletException, IOException {
        HttpServletRequest request = (HttpServletRequest) req;
        HttpServletResponse response = (HttpServletResponse) res;
        String path = request.getServletPath();
        if("/workbench/transaction/showTranList.do".equals(path)){
            showTranList(request,response);
        }else if("/workbench/transaction/findOwner.do".equals(path)){
            findOwner(request,response);
        }else if("/workbench/transaction/getCustomerName.do".equals(path)){
            getCustomerName(request,response);
        }else if("/workbench/transaction/findActivityByName.do".equals(path)){
            findActivityByName(request,response);
        }else if("/workbench/transaction/searchContactByName.do".equals(path)){
            searchContactByName(request,response);
        }else if("/workbench/transaction/saveTran.do".equals(path)){
            saveTran(request,response);
        }else if("/workbench/transaction/detail.do".equals(path)){
            detail(request,response);
        }else if("/workbench/transaction/findHistoryByTranId.do".equals(path)){
            findHistoryByTranId(request,response);
        }else if("/workbench/transaction/changeStage.do".equals(path)){
            changeStage(request,response);
        }else if("/workbench/chart/transaction/chartData.do".equals(path)){
            chartData(request,response);
        }
    }

    private void chartData(HttpServletRequest request, HttpServletResponse response) {
        TransactionService service = (TransactionService) ServiceFactory.getService(new TransactionServiceImpl());
        Map<String,Object> map = service.chartData();
        PrintJson.printJsonObj(response,map);
    }

    private void changeStage(HttpServletRequest request, HttpServletResponse response) {
        TransactionService service = (TransactionService) ServiceFactory.getService(new TransactionServiceImpl());
        String tranId = request.getParameter("tranId");
        String stage = request.getParameter("stage");
        User user = (User) request.getSession().getAttribute("userInfo");
        String editBy = user.getId();
        Map<String,String> spMap = (Map<String, String>) this.getServletContext().getAttribute("spMap");
        String possibility = spMap.get(stage);
        Map<String,Object> map = service.changeStage(stage,tranId,editBy,possibility);
        PrintJson.printJsonObj(response,map);
    }

    private void findHistoryByTranId(HttpServletRequest request, HttpServletResponse response) {
        TransactionService service = (TransactionService) ServiceFactory.getService(new TransactionServiceImpl());
        String tranId = request.getParameter("tranId");
        List<TranHistory> histories = service.getHistoriesByTranId(tranId);
        Map<String,String> spMap = (Map<String, String>) this.getServletContext().getAttribute("spMap");
        for(TranHistory history:histories){
            String stage = history.getStage();
            history.setPossibility(spMap.get(stage));
        }
        PrintJson.printJsonObj(response,histories);
    }

    private void detail(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        TransactionService service = (TransactionService) ServiceFactory.getService(new TransactionServiceImpl());
        String id = request.getParameter("id");
        Transaction tran = service.getTransactionById(id);
        Map<String,String> spMap = (Map<String, String>) this.getServletContext().getAttribute("spMap");
        String stage = tran.getStage();
        tran.setPossibility(spMap.get(stage));
        request.setAttribute("transactionInfo",tran);
        request.getRequestDispatcher("/workbench/transaction/detail.jsp").forward(request,response);
    }

    private void saveTran(HttpServletRequest request, HttpServletResponse response) {
        TransactionService service = (TransactionService) ServiceFactory.getService(new TransactionServiceImpl());
        String owner = request.getParameter("owner");
        String money = request.getParameter("money");
        String name = request.getParameter("name");
        String expectedDate = request.getParameter("expectedDate");
        String customerName = request.getParameter("customerName");
        String stage = request.getParameter("stage");
        String type = request.getParameter("type");
        String source = request.getParameter("source");
        String activityId = request.getParameter("activityId");
        String contactsId = request.getParameter("contactsId");
        String description = request.getParameter("description");
        String contactSummary = request.getParameter("contactSummary");
        String nextContactTime = request.getParameter("nextContactTime");
        Transaction tran = new Transaction();
        tran.setId(UUIDUtil.getUUID());
        tran.setOwner(owner);
        tran.setMoney(money);
        tran.setName(name);
        tran.setExpectedDate(expectedDate);
        //tran.setCustomerId();
        tran.setStage(stage);
        tran.setType(type);
        tran.setSource(source);
        tran.setActivityId(activityId);
        tran.setContactsId(contactsId);
        User user = (User) request.getSession().getAttribute("userInfo");
        tran.setCreateBy(user.getId());
        tran.setCreateTime(DateTimeUtil.getSysTime());
        tran.setDescription(description);
        tran.setContactSummary(contactSummary);
        tran.setNextContactTime(nextContactTime);

        boolean flag = service.saveTran(customerName,tran);

        PrintJson.printJsonFlag(response,flag);
    }

    private void searchContactByName(HttpServletRequest request, HttpServletResponse response) {
        String fullname = request.getParameter("fullname");
        TransactionService service = (TransactionService) ServiceFactory.getService(new TransactionServiceImpl());
        List<Contacts> cList = service.searchContactByName(fullname);
        PrintJson.printJsonObj(response,cList);
    }

    private void findActivityByName(HttpServletRequest request, HttpServletResponse response) {
        TransactionService service = (TransactionService) ServiceFactory.getService(new TransactionServiceImpl());
        String activityName = request.getParameter("activityName");
        List<Activity> aList = service.findActivityByName(activityName);
        PrintJson.printJsonObj(response,aList);
    }

    private void getCustomerName(HttpServletRequest request, HttpServletResponse response) {
        TransactionService service = (TransactionService) ServiceFactory.getService(new TransactionServiceImpl());
        String CustomerName = request.getParameter("name");
        List<String> cnames = service.getCustomerName(CustomerName);
        PrintJson.printJsonObj(response,cnames);
    }

    private void findOwner(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        TransactionService service = (TransactionService) ServiceFactory.getService(new TransactionServiceImpl());
        List<User> uList = service.findOwner();
        request.setAttribute("uList",uList);
        request.getRequestDispatcher("/workbench/transaction/save.jsp").forward(request,response);
    }

    private void showTranList(HttpServletRequest request, HttpServletResponse response) {
        TransactionService service = (TransactionService) ServiceFactory.getService(new TransactionServiceImpl());
        int pageNo = Integer.valueOf(request.getParameter("pageNo"));
        int pageSize = Integer.valueOf(request.getParameter("pageSize"));
        String owner = request.getParameter("owner");
        String name = request.getParameter("name");
        String customerName = request.getParameter("customerName");
        String tranStage = request.getParameter("tranStage");
        String tranType = request.getParameter("tranType");
        String tranSrc = request.getParameter("tranSrc");
        String contactName = request.getParameter("contactName");
        int skipRecordNum = (pageNo - 1) * pageSize;
        Map<String,Object> map = new HashMap<>();
        map.put("pageSize",pageSize);
        map.put("skipRecordNum",skipRecordNum);
        map.put("owner",owner);
        map.put("name",name);
        map.put("customerName",customerName);
        map.put("tranStage",tranStage);
        map.put("tranType",tranType);
        map.put("tranSrc",tranSrc);
        map.put("contactName",contactName);
        Pagination<Transaction> pagination = service.showTranList(map);
        PrintJson.printJsonObj(response,pagination);
    }
}
