function noctalia-r --description 'Restart Noctalia shell'
    pkill qs 2>/dev/null; nohup qs -c noctalia-shell > /dev/null 2>&1 &
end