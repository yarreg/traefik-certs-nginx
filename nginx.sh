#!/bin/sh

function tmpl()
{
    SCRIPT="
    /^[[:space:]]*@/! {
        s/'/'\\''/g;
        s/\${\(\([^}]\|\\}\)\+\)}/'"\${\\1}"'/g;
        s/^\(.*\)$/echo '\1'/;
    }
    s/^[[:space:]]*@//;"
    
    sed -e "$SCRIPT" $1 | sh > ${1%.*}
}

for file in $(find /etc/nginx -type f -name "*.tmpl")
do
    echo "Preparing nginx configuration file from template: $file"
    tmpl $file
done

# Starting nginx
nginx -g "daemon off;"
