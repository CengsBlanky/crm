package com.zengshuai.crm.workbench.dao;

import com.zengshuai.crm.settings.domain.User;
import com.zengshuai.crm.workbench.domain.Transaction;

import java.util.List;
import java.util.Map;

public interface TranDao {

    int createTran(Transaction transaction);

    int getTotalRecord(Map<String, Object> map);

    List<Transaction> getTranList(Map<String, Object> map);


    Transaction selectTranById(String id);

    int updateTran(Transaction upTran);

    List<Map<String, Object>> getchartData();

    int getMax();
}
