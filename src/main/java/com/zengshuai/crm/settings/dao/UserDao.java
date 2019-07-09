package com.zengshuai.crm.settings.dao;

import com.zengshuai.crm.settings.domain.User;

import java.util.List;
import java.util.Map;

public interface UserDao {
    User login(Map map);

    List<User> findOwner();
}
