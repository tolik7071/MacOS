//
//  main.cpp
//  asl_test
//
//  Created by Anatoliy Goodz on 10/2/17.
//  Copyright © 2017 Anatoliy Goodz. All rights reserved.
//

#define NEW_LOG

#include <iostream>
#if defined(NEW_LOG)
#include <os/log.h>
#else
#include <syslog.h>
#include <asl.h>
#endif // NEW_LOG
#include <assert.h>

int main(int argc, const char * argv[])
{
#if !defined(NEW_LOG)
    aslclient client = NULL;
    aslmsg messageTemplate = NULL;
    
    client = asl_open(NULL, "PreLoginAgents", 0);
    assert(client != NULL);
    
    int result = asl_set_filter(client, ASL_FILTER_MASK_UPTO(ASL_LEVEL_INFO));
    
    messageTemplate = asl_new(ASL_TYPE_MSG);
    assert(messageTemplate != NULL);
    
    result = asl_log(client, messageTemplate, ASL_LEVEL_INFO, "%s", "This is a test string!");
    assert(result == 0);
    
    asl_free(messageTemplate);
    asl_close(client);
#else
    os_log_t log = os_log_create("com.tolik.widget", "connections");
    assert(log != NULL);
    
    assert(os_log_debug_enabled(log));
    
    os_log(log, "connection state changed: %d.", 10);
#endif // NEW_LOG
    
    return 0;
}
