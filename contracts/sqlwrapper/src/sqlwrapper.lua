function constructor(ddlStr) 
    db.exec(ddlStr)
end

function execute(execStr)
    db.exec(execStr)
end

function query(queryStr)
    local rt = {}
    local rs = db.query(queryStr)

    while rs:next() do 
        local v = {rs:get()}
        table.insert(rt, v)
    end
    return rt
end

abi.register(execute, query)