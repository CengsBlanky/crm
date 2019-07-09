package com.zengshuai.crm.workbench.service.impl;

import com.zengshuai.crm.settings.dao.UserDao;
import com.zengshuai.crm.settings.domain.User;
import com.zengshuai.crm.utils.DateTimeUtil;
import com.zengshuai.crm.utils.SqlSessionUtil;
import com.zengshuai.crm.utils.UUIDUtil;
import com.zengshuai.crm.vo.Pagination;
import com.zengshuai.crm.workbench.dao.*;
import com.zengshuai.crm.workbench.domain.*;
import com.zengshuai.crm.workbench.service.TransactionService;


import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.UUID;

/**
*function:  -
*project:   crm
*author:    cengs
*version:   1.0 2019/7/5_20:37 
*/
public class TransactionServiceImpl implements TransactionService {
    TranDao tranDao = SqlSessionUtil.getSqlSession().getMapper(TranDao.class);
    CustomerDao customerDao = SqlSessionUtil.getSqlSession().getMapper(CustomerDao.class);
    ActivityDao activityDao = SqlSessionUtil.getSqlSession().getMapper(ActivityDao.class);
    ContactsDao contactsDao = SqlSessionUtil.getSqlSession().getMapper(ContactsDao.class);
    TranHistoryDao tranHistoryDao = SqlSessionUtil.getSqlSession().getMapper(TranHistoryDao.class);
    UserDao userDao = SqlSessionUtil.getSqlSession().getMapper(UserDao.class);
    @Override
    public Pagination<Transaction> showTranList(Map<String, Object> map) {
        int totalRecord = tranDao.getTotalRecord(map);
        List<Transaction> tranList = tranDao.getTranList(map);
        Pagination<Transaction> pagination = new Pagination<>();
        pagination.setTotalRecord(totalRecord);
        pagination.setDataList(tranList);
        return pagination;
    }

    @Override
    public List<User> findOwner() {
        return userDao.findOwner();
    }

    @Override
    public List<String> getCustomerName(String cname) {
        return customerDao.getCustomerName(cname);
    }

    @Override
    public List<Activity> findActivityByName(String activityName) {
        return activityDao.findActivityByName(activityName);
    }

    @Override
    public List<Contacts> searchContactByName(String fullname) {
        return contactsDao.searchContactByName(fullname);
    }

    @Override
    public boolean saveTran(String customerName, Transaction tran) {
        //查找顾客名称应的顾客信息（精确查找）
        Customer customer = customerDao.findCustomerByName(customerName);
        if(customer==null){
            //新建一条顾客信息
            customer = new Customer();
            customer.setId(UUIDUtil.getUUID());
            customer.setOwner(tran.getOwner());
            customer.setName(customerName);
            customer.setCreateBy(tran.getCreateBy());
            customer.setCreateTime(DateTimeUtil.getSysTime());
            customer.setContactSummary(tran.getContactSummary());
            customer.setNextContactTime(tran.getNextContactTime());
            int flag = customerDao.saveCustomer(customer);
            if(flag!=1){
                return false;
            }
        }else{
            //顾客存在，取出其id为tran.customerId赋值
            String customerId = customer.getId();
            tran.setCustomerId(customerId);
        }
        //存储交易
        int saveTranFlag = tranDao.createTran(tran);
        if(saveTranFlag!=1){
            return false;
        }
        //新建交易记录
        TranHistory history = new TranHistory();
        history.setId(UUIDUtil.getUUID());
        history.setStage(tran.getStage());
        history.setMoney(tran.getMoney());
        history.setExpectedDate(tran.getExpectedDate());
        history.setCreateTime(DateTimeUtil.getSysTime());
        history.setCreateBy(tran.getCreateBy());
        history.setTranId(tran.getId());
        int saveHistoryFlag = tranHistoryDao.createHistory(history);
        if(saveHistoryFlag!=1){
            return false;
        }
        return true;
    }

    @Override
    public Transaction getTransactionById(String id) {
        return tranDao.selectTranById(id);
    }

    @Override
    public List<TranHistory> getHistoriesByTranId(String tranId) {
        return tranHistoryDao.selectHistoriesByTranId(tranId);
    }

    @Override
    public Map<String, Object> changeStage(String stage, String tranId, String editBy,String possibility) {
        String editTime = DateTimeUtil.getSysTime();
        Transaction upTran = new Transaction();
        upTran.setId(tranId);
        upTran.setStage(stage);
        upTran.setEditBy(editBy);
        upTran.setEditTime(editTime);
        Map<String, Object> map = new HashMap<>();
        if (tranDao.updateTran(upTran)==1){
            Transaction tran = tranDao.selectTranById(tranId);
            tran.setPossibility(possibility);
            //创立一条交易历史
            TranHistory history = new TranHistory();
            history.setId(UUIDUtil.getUUID());
            history.setStage(stage);
            history.setMoney(tran.getMoney());
            history.setExpectedDate(tran.getExpectedDate());
            history.setCreateTime(DateTimeUtil.getSysTime());
            history.setCreateBy(editBy);
            history.setTranId(tran.getId());
            boolean flag = (tranHistoryDao.createHistory(history)==1);
            map.put("tran",tran);
            map.put("success",flag);
        }
        return map;

    }

    @Override
    public Map<String,Object> chartData() {
        Map<String,Object> map = new HashMap<>();
        int total = tranDao.getMax();
        List<Map<String,Object>> list = tranDao.getchartData();
        map.put("total",total);
        map.put("mapList",list);
        return map;

    }
}
