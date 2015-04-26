module Errors
  LIST = {
            invalid_credentials:            [1, 'Invalid login credentials'],
            invalid_token:                  [2, 'Invalid token'],

            unable_to_create_account:       [3, 'Unable to create account with the given credentials'],
            unable_to_update_password:      [4, 'Error occurred with updating password'],
            unable_to_update_account_info:  [5, 'Error occurred with updating account information'],

            token_to_delete_not_found:      [6, 'The token to delete was not found in the system'],
            token_user_mismatch:            [7, 'The token you are trying to delete does not belong to you'],

            unable_to_create_notification:  [8, 'Unable to create the notification'],
            notification_not_found:         [9, 'Notification was not found in the system'],
            unable_to_delete_notification:  [10, 'Error occurred when trying to delete the notification'],

            unknown_error:                  [999, 'Unknown error occurred']
           }
end