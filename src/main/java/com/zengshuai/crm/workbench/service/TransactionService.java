package com.zengshuai.crm.workbench.service;

import com.zengshuai.crm.settings.domain.User;
import com.zengshuai.crm.vo.Pagination;
import com.zengshuai.crm.workbench.domain.Activity;
import com.zengshuai.crm.workbench.domain.Contacts;
import com.zengshuai.crm.workbench.domain.TranHistory;
import com.zengshuai.crm.workbench.domain.Transaction;


import java.util.List;
import java.util.Map;

public interface TransactionService {
    Pagination<Transaction> showTranList(Map<String, Object> map);

    List<User> findOwner();

    List<String> getCustomerName(String cname);

    List<Activity> findActivityByName(String activityName);

    List<Contacts> searchContactByName(String fullname);

    boolean saveTran(String customerName, Transaction tran);

    Transaction getTransactionById(String id);

    List<TranHistory> getHistoriesByTranId(String tranId);

    Map<String, Object> changeStage(String stage, String tranId,String editBy,String possibility);

    Map<String,Object> chartData();
}
