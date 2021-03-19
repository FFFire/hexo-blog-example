---
title: 排序（C）
date: 2021-03-19 14:17:24
tags:
    - C
    - 算法
---

# 1. 前言

本文主要记录使用过的排序算法，之后有新的接触再更新。[我自己的工具函数仓库](https://github.com/lissettecarlr/Embedded-tool-function)
|名称|最坏时间复杂度|最好时间复杂度|空间复杂度|
|---|---|---|---|
|冒泡排序|O(n^2)|O(n)|O(1)|
|快速排序|O(n^2)|O(nlogn)|O(1)|
|哈希计数排序|O(n+k)|O(n+k)|O(k)|
<!-- more -->

# 2. 算法实现
## 2.1 冒泡排序
对于使用空间比较紧张的嵌入式应用来说，冒泡排序其实挺不错的，就是数据多了后速度非常慢。


* 最基本的写法

```
/*!
 * \brief 冒泡排序
 * \param [IN] arr 数据首地址
 * \param [IN] len 数据个数
 */
void BubbleSort(int arr[], int len)
{
    int temp;
    int j,i;
    for(i=0;i<len-1;i++)
    {
        for(j=0;j<len-1-i;j++)
        {
            if(arr[j]>arr[j+1])
            {
                temp = arr[j];
                arr[j] = arr[j+1];
                arr[j+1] = temp;
            }
        }
    }
}
```
* 通用类型的写法
对于嵌入式编程来说，用到int的情况可能是最少的了，都是些u8，u16这些，使用上面的函数就给你报传参警告，于是就需要一个通用点的函数。
```
#include <stdlib.h>
#include <string.h>

void swap(void *data1,void *data2,unsigned int size)
{
    if(size >8)return;
    unsigned char temp[8]; //不动态申请，假设最大为longlong
    memcpy(temp,data1,size);
    memcpy(data1,data2,size);
    memcpy(data2,temp,size);
}

/*!
 * \brief 冒泡排序
 * \param [IN] arr 数据首地址
 * \param [IN] len 数据个数
 * \param [IN] size 数据类型大小
 * \param [IN] compare 比较大小
 */
void BubbleSort(void *arr,unsigned int len,unsigned int size,int (*compare)(const void*a,const void*b))
{
    int i,j;
    for(i=0;i<len-1;i++)
    {
        for(j=0;j<len-1-i;j++)
        {
            if( compare(arr+j*size,arr+(j+1)*size) >0)
            {
                //printf("%d,%d  ",*(int *)(arr+j*size),*(int *)(arr+(j+1)*size));
                swap(arr+j*size,arr+(j+1)*size,size);
                //printf("%d,%d\n",*(int *)(arr+j*size),*(int *)(arr+(j+1)*size));
            }
        }
    }
}
```
使用方式：
```
/*
 * \brief 比较函数，网上很多是减法比较，但当参数是无符号时就完蛋了。
 */
int cmp(const void *a,const void *b)
{
    if( (*(int *)a) > (*(int *)b) )
    {
        return  1;
    }
    else
    {
        return -1;
    }
}
int main(void)
{
    int a[9] = {7,4,9,3,2,6,1,5,8};
    BubbleSort(a,9,sizeof(int),cmp);
    return 0;
}
```

## 2.2 快速排序
如其名，就是提升速度，但是也牺牲了内存，实现方式是递归，实际内存消耗不固定是个弊端。
* 下列实现直接使用库函数方式
```
/*!
 * \brief 快速排序，头文件:stdlib.h
 * \param [IN] base 数据首地址
 * \param [IN] nitems 数据个数
 * \param [IN] size 数据类型大小
 * \param [IN] compar 比较大小
 */
void qsort(void *base, size_t nitems, size_t size, int (*compar)(const void *, const void*));

//从小到大排序示例
int comp(const void*a,const void*b)
{
    if( (*(int *)a) > (*(int *)b) )
    {
        return  1;
    }
    else
    {
        return -1;
    }
}

int main(void)
{
    int a[9] = {7,4,9,3,2,6,1,5,8};
    qsort(a,9,sizeof(int),cmp);
    return 0;
}


```

## 3.3 哈希排序
利用哈希表来进行排序，将数据依次填入数组中，则依据数组下标达到排序的目的。优点在于耗时短，使用空间固定，缺点是得知道输入数据的范围。
```
#define HASH_SIZE 4096
static u8 hash[HASH_SIZE] = {0};
void leakSort(u16 *data,u16 size)
{
    int i=0;
    int j=0;
    memset(hash, 0, (HASH_SIZE) * sizeof(hash[0]));
    //填充hash表
    for (i = 0; i < size; i++) hash[data[i]]++;
    //按照顺序读出
    for (i = 0,j=0; i < (HASH_SIZE); i++) 
    {
        if (hash[i] > 0)
        {
            while (hash[i] != 0) 
            {
                data[j++] = i;
                hash[i]--;
            }
        }
    }
}
```
# 3. 实用示例


在进行中位值滤波的时候，我准备将整个数据先进行排序，然后去掉前百分之二十和后百分之二十，得到中间数据。
于是首先选择了冒泡排序，但是很明显的发现排序耗时严重，数据来源于ADC采集，每采集10ms进行一次数据处理，然后开始下一次采集。仿真测试10ms输入数据为350左右，排序耗时20ms，这肯定不能忍了，得换。
之后立马想到了快速排序，然后。。。程序崩了，原因是栈炸了，快速排序是递归，消耗的栈空间。一开始还没检测出来，原因在于消耗是和数据的值有关，动态的- -|。
最后选择了哈希表计数排序，一开始就给分配固定空间，虽然消耗挺大的，但是尽在掌握，稳定啊！测试实际耗时变为了2ms。能够接受了。
上列的数据仅仅是参考。。和片子速度有关哈。