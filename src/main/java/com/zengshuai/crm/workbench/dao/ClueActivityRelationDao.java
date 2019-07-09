package com.zengshuai.crm.workbench.dao;


import com.zengshuai.crm.workbench.domain.ClueActivityRelation;

public interface ClueActivityRelationDao {




    int insertIntoBundTable(ClueActivityRelation relation);

    int deleteRelation(ClueActivityRelation relation);

    String[] searchActivityIdByClueId(String clueId);

    int deleteRelationByClueId(String clueId);

    int toBeDeletedRelationCount(String clueId);
}
