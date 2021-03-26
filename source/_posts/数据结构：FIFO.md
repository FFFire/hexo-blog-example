---
title: 数据结构：FIFO
date: 2021-03-26 14:02:03
tags:
    - 数据结构
---
# 1. 前言
First Input First Output，先进先出队列，本文主要记录此结构的C实现，以下是一个循环队列，且当数据填满后，将抛弃旧数据存入新数据。直接用就请进入[此仓库](https://github.com/lissettecarlr/Embedded-tool-function)，在buffer/fifo文件夹下

<!-- more -->

# 2. 宏定义
* 是否在队列满的时候抛弃旧数据而存入新数据的开关宏，默认是开启的，不需要屏蔽即可
```
#define RING_OUT_THE_OLD
```
* 判断队列是否为空，当写地址等于读地址的时候认为队列为空
```
#define isFifoEmpty( fifo )                     ((fifo)->posR == (fifo)->posW)
```
* 判断队列是否为满，当写地址的下一个地址等于读地址，则认为为满。但由于当前写地址指向位置实际上是没有存入数据的，所以这样设计将会浪费掉一个存储区，也就是存储区域长度为3的时候，实际只能使用2.
```
#define isFifoFull( fifo )                      ((((fifo)->posW+1) % (fifo)->size) == (fifo)->posR)
```

# 3. 结构体
* 由于不想需求不同每次都去修改队列结构体，所以定义了一个枚举来代表存储器的数据类型，在初始化的时候传入，目前就只有两种，后面再添加
```
typedef enum 
{
    DATA_TYPE_U8=1,
    DATA_TYPE_U16=2,
}dataType_t;
```

* 队列结构体，用来保存实例队列的信息
```
typedef struct sFifo
{
    void *data; //数据存储区
    unsigned int size;//数据存储区大小
    unsigned int posR;//读地址
    unsigned int posW;//写地址
    dataType_t type;//存储区数据类型
}Fifo_t;
```

# 4. 功能函数

* 首先是初始化函数，实际上就是对实例进行填空
```
/*!
 * \brief 初始化队列
 * \param [IN] fifo 执行的队列
 * \param [IN] data 用于存储的区域
 * \param [IN] size 存储区域大小
 * \param [IN] type 存储数据类型
 */
void fifoInit(Fifo_t *fifo,void *data,unsigned int size,dataType_t type)
{
    fifo->data = data;
    fifo->size = size;
    fifo->type = type;
    fifo->posR = 0;
    fifo->posW = 0;
}
```

* 然后是存数据，其中根据初始化时候的数据类型，对传入data进行类型转换
```
int fifoPush(Fifo_t *fifo,void *data)
{
    if(isFifoFull(fifo) == 1)
    {
        //此宏用于启动队列满时新数据挤掉旧数据的功能
#ifndef RING_OUT_THE_OLD
        return -1;
#endif        
        //定义一个局部变量来取旧数据
        unsigned short temp;
        fifoPop(fifo,&temp);
    }

    if(fifo->type == DATA_TYPE_U8)
    {
       ((unsigned char *)(fifo->data))[fifo->posW] = *(unsigned char*)(data);
    }
    else if(fifo->type == DATA_TYPE_U16)
    {   
       ((unsigned short *)(fifo->data))[fifo->posW] = *(unsigned short*)(data);
    }
    else
    {
        return -1;
    }
    //更新下一次存储位置
    fifo->posW = (fifo->posW+1)%fifo->size;
    return 0;
}
```

* 之后是取数据
```
int fifoPop(Fifo_t *fifo,void *data)
{
    if( isFifoEmpty(fifo) == 1 )//为空
    {
        return -1;
    }

    if(fifo->type == DATA_TYPE_U8)
    {
        *(unsigned char *)data = ((unsigned char*)(fifo->data))[fifo->posR];
    }
    else if(fifo->type == DATA_TYPE_U16)
    {
        *(unsigned short*)data = ((unsigned short*)(fifo->data))[fifo->posR];
    }
    else
    {}
    fifo->posR = (fifo->posR+1) % fifo->size;
}
```

* 清空队列，实际就是修改读写地址为0，队列中实际位置的数据仍然存在。
```
void fifoClear(Fifo_t *fifo)
{
    fifo->posR = 0;
    fifo->posW = 0;
}
```

* 获取队列当前数据个数
```
unsigned int fifoLenth(Fifo_t *fifo)
{
    unsigned int len;

    len = (fifo->posW + fifo->size - fifo->posR) % fifo->size;

    return len;
}
```

# 5. 使用
使用方式，github仓库中fifo文件夹下的main函数有示例，例如

```
    unsigned char a[10]={0};
    Fifo_t buffer;
    unsigned char w1=1,w2=2;
    unsigned char r1=0,r2=0;

    fifoInit(&buffer,a,10,DATA_TYPE_U8);
    fifoPush(&buffer,&w1);
    fifoPush(&buffer,&w2);
    printf("test_u8: fifo len:%d\n",fifoLenth(&buffer));
    fifoPop(&buffer,&r1);
    fifoPop(&buffer,&r2);
    printf("test_u8: r1:%d,r2:%d\n",r1,r2);

```
或者
```
    unsigned short a[10]={0};
    Fifo_t buffer;
    unsigned short w1=0x1234,w2=0x4321;
    unsigned short r1=0,r2=0;

    fifoInit(&buffer,a,10,DATA_TYPE_U16);
    fifoPush(&buffer,&w1);
    fifoPush(&buffer,&w2);
    printf("test_u16: fifo len:%d\n",fifoLenth(&buffer));
    fifoPop(&buffer,&r1);
    fifoPop(&buffer,&r2);
    printf("test_u16: r1:%04X,r2:%04X\n",r1,r2);
```