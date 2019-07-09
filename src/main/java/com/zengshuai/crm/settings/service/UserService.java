package com.zengshuai.crm.settings.service;

import com.zengshuai.crm.exception.LoginException;
import com.zengshuai.crm.settings.domain.User;


public interface UserService {
    User login(String loginAct,String lgoinPwd,String ip) throws LoginException;
}
