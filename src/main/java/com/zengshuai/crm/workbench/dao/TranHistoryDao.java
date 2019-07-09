package com.zengshuai.crm.workbench.dao;

import com.zengshuai.crm.workbench.domain.TranHistory;

import java.util.List;

public interface TranHistoryDao {

    int createHistory(TranHistory history);


    List<TranHistory> selectHistoriesByTranId(String tranId);
}
