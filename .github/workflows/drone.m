a = input("Enter a time: ")
t1 = datetime('now');
t2 = t1 + hours(a)

t2.Format = 'yyyy-MM-dd hh:mm:ss'
fprintf("%d hours from the current time, it is %s\n",a, t2)
