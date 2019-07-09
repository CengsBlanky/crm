package com.zengshuai.crm.workbench.dao;


import com.zengshuai.crm.settings.domain.User;
import com.zengshuai.crm.workbench.domain.Activity;
import com.zengshuai.crm.workbench.domain.Clue;


import java.util.List;
import java.util.Map;

public interface ClueDao {
    List<User> findUsers();

    int getTotalRecord(Map<String, Object> map);

    List<Clue> getClueList(Map<String, Object> map);

    int saveClue(Clue clue);

    Clue getClueById(String id);

    List<Activity> findActivities(String clueId);

    List<Activity> searchActivityByName(Map<String, String> map);

    List<Activity> searchActivityOnlyByName(String aname);

    Clue findClueById(String clueId);

    int deleteClueById(String clueId);
}
