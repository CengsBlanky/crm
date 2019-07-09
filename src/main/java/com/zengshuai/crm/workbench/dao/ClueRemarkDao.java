package com.zengshuai.crm.workbench.dao;

import com.zengshuai.crm.workbench.domain.ClueRemark;

import java.util.List;

public interface ClueRemarkDao {

    List<ClueRemark> searchRemarkByClueId(String clueId);

    int deleteRemarkByClueId(String clueId);

    int toBeDeletedCount(String clueId);
}
