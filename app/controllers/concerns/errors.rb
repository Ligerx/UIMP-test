module Errors
  LIST = {
            invalid_credentials:            [101, 'Invalid login credentials'],
            invalid_token:                  [102, 'Invalid token'],

            unable_to_create_account:       [201, 'Unable to create account with the given credentials'],
            unable_to_update_password:      [202, 'Error occurred with updating password'],
            unable_to_update_account_info:  [203, 'Error occurred with updating account information'],

            token_to_delete_not_found:      [301, 'The token to delete was not found in the system'],
            token_user_mismatch:            [302, 'The token you are trying to delete does not belong to you'],

            unable_to_create_notification:  [401, 'Unable to create the notification'],
            notification_not_found:         [402, 'Notification was not found in the system'],
            unable_to_delete_notification:  [403, 'Error occurred when trying to delete the notification'],

            unknown_error:                  [999, 'Unknown error occurred']
           }
end