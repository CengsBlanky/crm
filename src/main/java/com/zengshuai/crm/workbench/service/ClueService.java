package com.zengshuai.crm.workbench.service;

import com.zengshuai.crm.exception.ConvertException;
import com.zengshuai.crm.settings.domain.User;
import com.zengshuai.crm.vo.Pagination;
import com.zengshuai.crm.workbench.domain.Activity;
import com.zengshuai.crm.workbench.domain.Clue;
import com.zengshuai.crm.workbench.domain.Transaction;

import java.util.List;
import java.util.Map;

public interface ClueService {
    List<User> findUsers();

    Pagination<Clue> disClueList(Map<String, Object> map);

    boolean saveClue(Clue clue);

    Clue getClueById(String id);

    List<Activity> findActivities(String clueId);

    List<Activity> searchActivityByName(String aname, String clueId);

    boolean bundActivity(String clueId, String[] activityIds);

    List<Activity> searchActivityOnlyByName(String aname);

    boolean deleteRelation(String clueId, String aId);

    void convert (Transaction transaction, String clueId) throws ConvertException;
}
