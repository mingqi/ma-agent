jsparser = require './javascript'




module.exports = (db, shell) ->

  execExpression = (expression) =>
    switch expression.type
      when "CallExpression"
        return call(expression)
      when "MemberExpression"
        [obj, prop_name] = member(expression)
        return obj[prop_name]
      else
        throw new Error("express only support call and member") 

  member = (member_expression) ->
    # console.log member_expression
    obj = null
    if member_expression.object.type == 'Identifier'
      if member_expression.object.name != 'db'
        throw new Error("'#{member_expression.object.name}' is not a allowed identify")
      else
        obj = db

    else
      obj = execExpression(member_expression.object)

    return [obj, member_expression.property.name]

  call = (call_expression) ->
    callee = call_expression.callee
    if callee.type != 'MemberExpression'
      throw new Error("syntax Error: funcation call must be a member of object")

    [obj, prop_name] = member(callee)
    return obj[prop_name].apply(obj, [])
  

  syntax_tree = jsparser.parse(shell) 
  exp = syntax_tree.body[0].expression
  console.log syntax_tree
  console.log exp.arguments[0]

  return execExpression(exp)
